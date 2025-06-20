import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String channelName;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.channelName,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _videoPlayerController;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VlcPlayerController.network(
        widget.videoUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
          ]),
        ),
      );

      _videoPlayerController.addListener(() {
        if (!mounted) return;

        final isPlaying = _videoPlayerController.value.isPlaying;
        final isBuffering = _videoPlayerController.value.isBuffering;

        if (isBuffering != _isBuffering) {
          setState(() => _isBuffering = isBuffering);
        }

        if (isPlaying != _isPlaying) {
          setState(() => _isPlaying = isPlaying);
        }

        if (!_isInitialized && _videoPlayerController.value.isInitialized) {
          setState(() => _isInitialized = true);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize player: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        actions: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),
        ],
      ),
      body: Center(
        child: _isInitialized
            ? Column(
                children: [
                  Expanded(
                    child: VlcPlayer(
                      controller: _videoPlayerController,
                      aspectRatio: 16 / 9,
                      placeholder: Center(child: _buildLoadingIndicator()),
                    ),
                  ),
                  _buildControls(),
                ],
              )
            : _buildLoadingIndicator(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Initializing player...'),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: () {}, // Implement previous channel
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: () {}, // Implement next channel
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {}, // Implement fullscreen
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    _isPlaying ? _videoPlayerController.pause() : _videoPlayerController.play();
  }
}
