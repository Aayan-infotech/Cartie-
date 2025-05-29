import 'dart:async';

import 'package:cartie/core/models/course_model.dart';
import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/theme/theme_provider.dart';
import 'package:cartie/core/utills/branded_primary_button.dart';
import 'package:cartie/features/providers/course_provider.dart';
import 'package:cartie/features/video_player/assisment_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class TrainingDetailScreen extends StatefulWidget {
  const TrainingDetailScreen({super.key});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int _currentVideoIndex = 0;
  bool _isInitialized = false;
  int _selectedTabIndex = 1;
  late CourseProvider _courseProvider;
  bool _isVideoEnded = false;
  Timer? _progressSaveTimer; // Added for progress throttling
  DateTime _lastSaveTime = DateTime.now(); // Added for progress throttling

  List<String> _videoUrls = [];
  List<Section> _uiSections = [];
  List<Video> _allVideos = [];

  @override
  void initState() {
    super.initState();
    _courseProvider = Provider.of<CourseProvider>(context, listen: false);
    _courseProvider.addListener(_onProviderUpdate);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _courseProvider.fetchCourseSections();
    });
  }

  void _onProviderUpdate() {
    if (!mounted) return;

    if (_courseProvider.sections != null) {
      final course = _courseProvider.sections!;
      final newVideoUrls = course.sections
          .expand((section) => section.videos.map((v) => v.url))
          .toList();
      _allVideos = course.sections.expand((s) => s.videos).toList();
      final newUISections = _convertToUISections(course);

      if (mounted) {
        setState(() {
          _videoUrls = newVideoUrls;
          _uiSections = newUISections;
        });
      }

      if (newVideoUrls.isNotEmpty) {
        if (_currentVideoIndex >= newVideoUrls.length || !_isInitialized) {
          _currentVideoIndex = 0;
        }
        _initializeVideo(_currentVideoIndex);
      }
    }
  }

  List<Section> _convertToUISections(Course course) {
    List<Section> uiSections = [];
    int lessonIndex = 1;
    int videoIndexCounter = 0;

    for (int i = 0; i < course.sections.length; i++) {
      final apiSection = course.sections[i];
      final isFirstSection = i == 0;
      final isSectionUnlocked = isFirstSection
          ? true
          : course.sections[i - 1].test.nextSectionUnlocked;

      List<Lesson> lessons = [];
      bool previousCompleted = isSectionUnlocked;

      for (var video in apiSection.videos) {
        lessons.add(Lesson(
          index: lessonIndex++,
          title: video.title,
          time: video.durationTime,
          videoIndex: videoIndexCounter++,
          isLessionCompleted: video.isCompleted,
          isUnlocked: previousCompleted,
        ));
        previousCompleted = video.isCompleted;
      }

      uiSections.add(Section(
        isNextSectionUnnlocked: apiSection.test.nextSectionUnlocked,
        isTestPass: apiSection.test.isSectionCompleted,
        id: apiSection.id,
        sectionNumber: apiSection.sectionNumber,
        title: 'Section ${apiSection.sectionNumber} - ${apiSection.title}',
        duration: apiSection.durationTime,
        lessons: lessons,
        isSectionCompleted: apiSection.isSectionCompleted,
      ));
    }
    return uiSections;
  }

  // NEW: Helper to unlock next video in UI
  void _optimisticallyUnlockNextVideo() {
    setState(() {
      // Unlock next lesson in same section
      for (final section in _uiSections) {
        for (int i = 0; i < section.lessons.length; i++) {
          if (section.lessons[i].videoIndex == _currentVideoIndex &&
              i < section.lessons.length - 1) {
            section.lessons[i + 1].isUnlocked = true;
            break;
          }
        }
      }
    });
  }

  Future<void> _initializeVideo(int index) async {
    if (index >= _videoUrls.length) return;
    final currentSection = _uiSections.firstWhere(
      (s) => s.lessons.any((l) => l.videoIndex == index),
      orElse: () => throw Exception('Section not found'),
    );

    final lesson = currentSection.lessons.firstWhere(
      (l) => l.videoIndex == index,
    );

    if (!lesson.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Complete previous videos to unlock this one')),
      );
      return;
    }
    final currentVideo = _allVideos[index];
    final newController =
        VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
    await newController.initialize();

    // COMBINED LISTENER (replaces two separate listeners)
    newController.addListener(() async {
      if (!mounted) return;
      final value = newController.value;

      // 1. Handle video completion
      if (value.duration > Duration.zero &&
          value.position >= value.duration &&
          !_isVideoEnded) {
        _isVideoEnded = true;

        // Only mark as completed if not already completed
        if (!currentVideo.isCompleted) {
          await _courseProvider.markVideoCompleted(
            locationId: _courseProvider.sections!.location,
            sectionId: currentVideo.sectionId,
            videoId: currentVideo.id,
          );
          // Optimistically unlock next video in UI
          _optimisticallyUnlockNextVideo();
        }
      }
      // Reset ended flag if not at end
      else if (value.position < value.duration) {
        _isVideoEnded = false;
      }

      // 2. Throttled progress saving
      if (!value.isPlaying &&
          value.position < value.duration &&
          DateTime.now().difference(_lastSaveTime) >
              const Duration(seconds: 2)) {
        _lastSaveTime = DateTime.now();
        _progressSaveTimer?.cancel();
        _progressSaveTimer = Timer(const Duration(seconds: 1), () async {
          await _courseProvider.updateVideoProgress(
            locationId: _courseProvider.sections!.location,
            sectionId: currentVideo.sectionId,
            videoId: currentVideo.id,
            watchedDuration: value.position.inSeconds.toString(),
          );
        });
      }
    });

    // Restore saved progress if not completed
    if (!currentVideo.isCompleted) {
      final savedPosition = currentVideo.watchedDuration;
      if (savedPosition != null) {
        await newController.seekTo(Duration(seconds: savedPosition));
      }
    }

    if (mounted) {
      _videoController?.dispose();
      _chewieController?.dispose();

      setState(() {
        _videoController = newController;
        _isInitialized = true;

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.lightGreen,
          ),
          placeholder: Container(color: Colors.grey),
          customControls: const CupertinoControls(
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
            iconColor: Colors.white,
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
      });
    } else {
      newController.dispose();
    }
  }

  void _changeVideo(int index) async {
    if (index != _currentVideoIndex && index < _videoUrls.length) {
      // Save current video progress
      if (_videoController != null && _videoController!.value.isInitialized) {
        final currentPosition = _videoController!.value.position;
        final currentVideo = _allVideos[_currentVideoIndex];
        if (currentPosition < _videoController!.value.duration) {
          await _courseProvider.updateVideoProgress(
            locationId: _courseProvider.sections!.location,
            sectionId: currentVideo.sectionId,
            videoId: currentVideo.id,
            watchedDuration: currentPosition.inSeconds.toString(),
          );
        }
      }

      setState(() {
        _currentVideoIndex = index;
        _isInitialized = false;
      });

      await _videoController?.dispose();
      await _initializeVideo(index);
    }
  }

  @override
  void dispose() {
    _courseProvider.removeListener(_onProviderUpdate);
    _progressSaveTimer?.cancel(); // Cancel timer on dispose

    if (_videoController != null && _videoController!.value.isInitialized) {
      final currentPosition = _videoController!.value.position;
      final currentVideo = _allVideos[_currentVideoIndex];
      if (currentPosition < _videoController!.value.duration) {
        _courseProvider.updateVideoProgress(
          locationId: _courseProvider.sections!.location,
          sectionId: currentVideo.sectionId,
          videoId: currentVideo.id,
          watchedDuration: currentPosition.inSeconds.toString(),
        );
      }
    }
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.onBackground,
        title: Text(
          'Training',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalVideos = _videoUrls.length;
          final currentVideo = _currentVideoIndex < _allVideos.length
              ? _allVideos[_currentVideoIndex]
              : null;

          return provider.sections.location.isEmpty
              ? _buildEmptySectionPlaceholder(colorScheme)
              : Column(children: [
                  _isInitialized &&
                          _videoUrls.isNotEmpty &&
                          _chewieController != null
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Chewie(controller: _chewieController!),
                        )
                      : const AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          if (currentVideo != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(currentVideo.title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface)),
                                    ),
                                    const Spacer(),
                                    Text(currentVideo.durationTime,
                                        style: TextStyle(
                                            color:
                                                colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.video_collection,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 16),
                              const SizedBox(width: 4),
                              Text('$totalVideos Videos',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 16),
                              const SizedBox(width: 4),
                              Text(provider.sections.totalDuration,
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant)),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildTabButton(0, 'About', colorScheme),
                              const SizedBox(width: 10),
                              _buildTabButton(1, 'Curriculum', colorScheme),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _selectedTabIndex == 0
                              ? _buildAboutTab(textTheme, colorScheme,
                                  provider.sections?.location ?? '')
                              : _buildCurriculumTab(colorScheme),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ]);
        },
      ),
    );
  }

  Widget _buildTabButton(int index, String label, ColorScheme colorScheme) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: isSelected ? Colors.white : colorScheme.onSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(
      TextTheme textTheme, ColorScheme colorScheme, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Course Description',
            style:
                textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        Text(description,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5)),
      ],
    );
  }

  Widget _buildCurriculumTab(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _uiSections
          .map((section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title,
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 6),
                  Text('Duration: ${section.duration}',
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...section.lessons.map(
                    (lesson) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: lesson.isUnlocked
                          ? () => _changeVideo(lesson.videoIndex)
                          : null,
                      leading: Icon(
                        lesson.isUnlocked
                            ? (_currentVideoIndex == lesson.videoIndex
                                ? Icons.pause
                                : Icons.play_circle_fill)
                            : Icons.lock_outline,
                        color: lesson.isUnlocked
                            ? (_currentVideoIndex == lesson.videoIndex
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant)
                            : Colors.grey,
                        size: 28,
                      ),
                      title: Text(
                        '${lesson.index}. ${lesson.title}',
                        style: GoogleFonts.montserrat(
                          color: lesson.isUnlocked
                              ? (_currentVideoIndex == lesson.videoIndex
                                  ? colorScheme.primary
                                  : colorScheme.onSurface)
                              : Colors.grey,
                          fontWeight: _currentVideoIndex == lesson.videoIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(lesson.time,
                          style: GoogleFonts.montserrat(
                            color: lesson.isUnlocked
                                ? (_currentVideoIndex == lesson.videoIndex
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant)
                                : Colors.grey,
                          )),
                      trailing: lesson.isLessionCompleted
                          ? Icon(Icons.check_circle,
                              color: colorScheme.primary, size: 20)
                          : (lesson.isUnlocked
                              ? null
                              : Icon(Icons.lock, size: 20)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BrandedPrimaryButton(
                    isEnabled:
                        section.isSectionCompleted && !section.isTestPass,
                    name: section.isTestPass ? "Passed" : "Take Assessment",
                    onPressed: () async {
                      if (!section.isSectionCompleted) return;

                      final courseProvider =
                          Provider.of<CourseProvider>(context, listen: false);
                      await courseProvider.fetchQuiz(
                        locationId: _courseProvider.sections.location,
                        sectionId: section.id,
                        sectionNumber: section.sectionNumber,
                      );

                      if (mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AssessmentScreen(
                              locationId: _courseProvider.sections.location,
                              sectionId: section.id,
                              sectionNumber: section.sectionNumber,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildEmptySectionPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_sharp,
              size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('No videos available in this location',
              style: GoogleFonts.montserrat(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          Text('Check back later for updates!',
              style: GoogleFonts.montserrat(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              )),
        ],
      ),
    );
  }
}

class Section {
  final String id;
  final int sectionNumber;
  final String title;
  final String duration;
  final List<Lesson> lessons;
  bool isSectionCompleted;
  bool isNextSectionUnnlocked;
  bool isTestPass;

  Section({
    required this.isNextSectionUnnlocked,
    required this.isTestPass,
    required this.id,
    required this.sectionNumber,
    required this.title,
    required this.duration,
    required this.lessons,
    required this.isSectionCompleted,
  });
}

class Lesson {
  final int index;
  final String title;
  final String time;
  final int videoIndex;
  bool isLessionCompleted;
  bool isUnlocked;

  Lesson({
    required this.isUnlocked,
    required this.index,
    required this.title,
    required this.time,
    required this.videoIndex,
    required this.isLessionCompleted,
  });
}
