import 'package:cartie/features/providers/dash_board_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoScreen({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoScreen> createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _noVideoAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideoPlayer();
    });
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final provider = Provider.of<DashBoardProvider>(context, listen: false);
      await provider.getSeftyVideo();

      if (provider.seftyVideoUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _noVideoAvailable = true;
            _isInitialized = true;
          });
        }
        return;
      }

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(provider.seftyVideoUrl),
      );

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
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
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _noVideoAvailable = true;
          _isInitialized = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_chewieController?.isPlaying ?? false) {
      _chewieController?.pause();
    } else {
      _chewieController?.play();
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          "Safety Video",
          style: theme.textTheme.displayLarge,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.iconTheme,
        titleTextStyle: theme.textTheme.displayLarge,
      ),
      body: _buildBodyContent(theme),
    );
  }

  Widget _buildBodyContent(ThemeData theme) {
    if (_noVideoAvailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 64,
                color: theme.colorScheme.secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              Text(
                "No Safety Video Available",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "There is currently no safety video available for your location.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading Safety Video...",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: Chewie(controller: _chewieController!)),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
