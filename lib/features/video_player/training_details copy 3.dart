import 'package:cartie/core/utills/custom_slider.dart';
import 'package:cartie/features/video_player/assisment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slider_button_lite/slider_button_lite.dart';
import 'package:video_player/video_player.dart';

class TrainingDetailScreen extends StatefulWidget {
  const TrainingDetailScreen({super.key});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  late VideoPlayerController _controller;
  int _currentVideoIndex = 0;
  bool _isInitialized = false;

  final List<String> _videoUrls = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ];

  final List<Section> _sections = [
    Section(
      title: 'Section 01 - Introduction',
      duration: '25 Mins',
      lessons: [
        Lesson(index: 1, title: 'Lesson 1', time: '15 Mins', videoIndex: 0),
        Lesson(index: 2, title: 'Lesson 2', time: '10 Mins', videoIndex: 1),
      ],
    ),
    Section(
      title: 'Section 02 - Graphic Design',
      duration: '55 Mins',
      lessons: [
        Lesson(index: 3, title: 'Lesson 3', time: '30 Mins', videoIndex: 2),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideo(_currentVideoIndex);
  }

  Future<void> _initializeVideo(int index) async {
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(_videoUrls[index]));
    await _controller.initialize();
    setState(() => _isInitialized = true);
    _controller.addListener(() => setState(() {}));
    _controller.setLooping(true);
    _controller.play();
  }

  void _changeVideo(int index) async {
    if (_currentVideoIndex == index) return;
    _currentVideoIndex = index;
    await _controller.pause();
    await _controller.dispose();
    _isInitialized = false;
    setState(() {});
    await _initializeVideo(index);
  }

  void _seekForward() {
    final currentPosition = _controller.value.position;
    final targetPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(targetPosition);
  }

  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final targetPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(
        targetPosition >= Duration.zero ? targetPosition : Duration.zero);
  }

  void _enterFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(controller: _controller),
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Training 1',
            style: GoogleFonts.montserrat(
                fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _isInitialized
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          iconSize: 60,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10,
                                    color: Colors.white),
                                onPressed: _seekBackward,
                              ),
                              IconButton(
                                icon: const Icon(Icons.fullscreen,
                                    color: Colors.white),
                                onPressed: _enterFullScreen,
                              ),
                              IconButton(
                                icon: const Icon(Icons.forward_10,
                                    color: Colors.white),
                                onPressed: _seekForward,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(child: CircularProgressIndicator()),
                ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Text('Horem ipsum',
                          style: GoogleFonts.montserrat(color: Colors.red)),
                      const Spacer(),
                      const Text('Required min 7',
                          style: TextStyle(color: Colors.white70)),
                      const Icon(Icons.star, color: Colors.yellow, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Horem ipsum dolor sit cing elit...',
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.video_collection,
                          color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text('21 Videos',
                          style: TextStyle(color: Colors.white70)),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, color: Colors.white70, size: 16),
                      SizedBox(width: 4),
                      Text('42 Hours', style: TextStyle(color: Colors.white70)),
                      Spacer(),
                      Text('\$28',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTabButton('About', false),
                      const SizedBox(width: 10),
                      _buildTabButton('Curriculum', true),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._sections.map(_buildSection),
                  const SizedBox(height: 20),
                  SliderButton(
                    properties: SliderButtonProperties(
                      disable: false,
                      isLoading: false,
                      disableButtonColor: const Color(0xFFCCCCDD),
                      width: MediaQuery.of(context).size.width - (16 * 2),
                      dismissThresholds: 0.90,
                      backgroundColor: Colors.red,
                      action: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AssessmentScreen(),
                          ),
                        );
                        return true; // Return true to keep slider completed
                      },
                      label: const Text(
                        'Slide to confirm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      buttonSize: 60,
                      alignLabel: Alignment.center,
                      icon: const ClipOval(
                        child: Material(
                          color: Colors.black,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.red : Colors.grey[850],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: GoogleFonts.montserrat(color: Colors.white)),
      ),
    );
  }

  Widget _buildSection(Section section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(section.title,
                style: GoogleFonts.montserrat(color: Colors.redAccent)),
            const Spacer(),
            Text(section.duration,
                style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 8),
        ...section.lessons.map(_buildLessonTile),
      ],
    );
  }

  Widget _buildLessonTile(Lesson lesson) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text('${lesson.index}',
            style: const TextStyle(color: Colors.black)),
      ),
      title: Text(lesson.title,
          style: GoogleFonts.montserrat(color: Colors.white)),
      subtitle:
          Text(lesson.time, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.play_circle_fill, color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: () => _changeVideo(lesson.videoIndex),
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    void seekForward() {
      final currentPosition = controller.value.position;
      final target = currentPosition + const Duration(seconds: 10);
      controller.seekTo(target);
    }

    void seekBackward() {
      final currentPosition = controller.value.position;
      final target = currentPosition - const Duration(seconds: 10);
      controller.seekTo(target >= Duration.zero ? target : Duration.zero);
    }

    void togglePlayPause() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: IconButton(
                  iconSize: 60,
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                  ),
                  onPressed: togglePlayPause,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.red,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        onPressed: seekBackward,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        onPressed: seekForward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
