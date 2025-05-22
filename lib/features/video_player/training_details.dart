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
        if (!_isInitialized || _currentVideoIndex >= newVideoUrls.length) {
          _currentVideoIndex = 0;
          _initializeVideo(_currentVideoIndex);
        }
      }
    }
  }

  List<Section> _convertToUISections(Course course) {
    List<Section> uiSections = [];
    int lessonIndex = 1;
    int videoIndexCounter = 0;

    for (var section in course.sections) {
      List<Lesson> lessons = [];
      for (var video in section.videos) {
        lessons.add(Lesson(
          index: lessonIndex++,
          title: video.title,
          time: video.durationTime,
          videoIndex: videoIndexCounter++,
        ));
      }
      uiSections.add(Section(
        title: 'Section ${section.sectionNumber} - ${section.title}',
        duration: section.durationTime,
        lessons: lessons,
      ));
    }
    return uiSections;
  }

  Future<void> _initializeVideo(int index) async {
    if (index >= _videoUrls.length) return;

    final currentVideo = _allVideos[index];
    final newController =
        VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
    await newController.initialize();

    // Check for saved progress
    final savedPosition = currentVideo
        .watchedDuration; //_courseProvider.getVideoProgress(currentVideo.id);
    if (savedPosition != null) {
      await newController.seekTo(Duration(seconds: savedPosition));
    }

    // Add listener to save progress on pause
    newController.addListener(() async {
      if (!newController.value.isPlaying &&
          newController.value.position < newController.value.duration) {
        await _courseProvider.updateVideoProgress(
          locationId: _courseProvider.sections!.location,
          sectionId: currentVideo.sectionId,
          videoId: currentVideo.id,
          watchedDuration: newController.value.position.inSeconds.toString(),
        );
      }
    });

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
              locationId: _courseProvider.sections!.id,
              sectionId: currentVideo.sectionId,
              videoId: currentVideo.id,
              watchedDuration: currentPosition.inSeconds.toString());
        }
      }

      _currentVideoIndex = index;
      await _chewieController?.pause();
      await _videoController?.dispose();
      if (mounted) {
        setState(() => _isInitialized = false);
      }
      await _initializeVideo(index);
    }
  }

  @override
  void dispose() {
    _courseProvider.removeListener(_onProviderUpdate);
    // Save progress when screen is disposed
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

          return Column(children: [
            _isInitialized && _videoUrls.isNotEmpty && _chewieController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(
                      child: _videoUrls.isEmpty
                          ? const CircularProgressIndicator()
                          : const Text('No videos available'),
                    ),
                  ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
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
                                width: MediaQuery.of(context).size.width * 0.7,
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
                                      color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.video_collection,
                            color: colorScheme.onSurfaceVariant, size: 16),
                        const SizedBox(width: 4),
                        Text('$totalVideos Videos',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            color: colorScheme.onSurfaceVariant, size: 16),
                        const SizedBox(width: 4),
                        Text('42 Hours',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
                        const Spacer(),
                        Text('\$28',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
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
                            _courseProvider.sections?.location ?? '')
                        : _buildCurriculumTab(colorScheme),
                    const SizedBox(height: 20),
                    if (_selectedTabIndex != 0)
                      BrandedPrimaryButton(
                        isEnabled: true,
                        name: "Take Assessment",
                        // In TrainingDetailScreen's "Take Assessment" button:
                        onPressed: () async {
                          final courseProvider = Provider.of<CourseProvider>(
                              context,
                              listen: false);
                          final currentVideo = _allVideos[_currentVideoIndex];
                          final currentSection =
                              _courseProvider.sections!.sections.firstWhere(
                            (s) => s.id == currentVideo.sectionId,
                          );

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AssessmentScreen(
                                locationId: courseProvider.sections!.location,
                                sectionId: currentVideo.sectionId,
                                sectionNumber: currentSection.sectionNumber,
                              ),
                            ),
                          );
                        },
                      ),
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
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    print(isLightTheme);
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
              color: isLightTheme ? Colors.white : colorScheme.onPrimary,
              //: colorScheme.onSecondary,
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
                      onTap: () => _changeVideo(lesson.videoIndex),
                      leading: Icon(
                        _currentVideoIndex == lesson.videoIndex
                            ? Icons.pause
                            : Icons.play_circle_fill,
                        color: _currentVideoIndex == lesson.videoIndex
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      title: Text(
                        '${lesson.index}. ${lesson.title}',
                        style: GoogleFonts.montserrat(
                          color: _currentVideoIndex == lesson.videoIndex
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                          fontWeight: _currentVideoIndex == lesson.videoIndex
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(lesson.time,
                          style: GoogleFonts.montserrat(
                            color: _currentVideoIndex == lesson.videoIndex
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          )),
                      trailing: _currentVideoIndex == lesson.videoIndex
                          ? Icon(Icons.check_circle,
                              color: colorScheme.primary, size: 20)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ))
          .toList(),
    );
  }
}

class Section {
  final String title;
  final String duration;
  final List<Lesson> lessons;

  Section({
    required this.title,
    required this.duration,
    required this.lessons,
  });
}

class Lesson {
  final int index;
  final String title;
  final String time;
  final int videoIndex;

  Lesson({
    required this.index,
    required this.title,
    required this.time,
    required this.videoIndex,
  });
}
