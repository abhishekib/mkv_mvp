// screens/video/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:goodchannel/viewmodels/video_viewmodel.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoPlayerViewModel>().initializePlayer(widget.videoUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        actions: [
          IconButton(
            icon: Icon(context.watch<VideoPlayerViewModel>().isPlaying
                ? Icons.pause
                : Icons.play_arrow),
            onPressed: () =>
                context.read<VideoPlayerViewModel>().togglePlayPause(),
          ),
        ],
      ),
      body: _buildPlayerBody(),
    );
  }

  Widget _buildPlayerBody() {
    final vm = context.watch<VideoPlayerViewModel>();

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${vm.errorMessage}', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => vm.retryInitialization(widget.videoUrl),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!vm.isInitialized || vm.controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Initializing player...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: VlcPlayer(
            controller: vm.controller!,
            aspectRatio: 16 / 9,
          ),
        ),
        if (vm.isBuffering) const LinearProgressIndicator(),
      ],
    );
  }

  @override
  void dispose() {
    context.read<VideoPlayerViewModel>().dispose();
    super.dispose();
  }
}
