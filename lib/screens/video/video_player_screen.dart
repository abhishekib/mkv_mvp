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
  bool _canShowPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<VideoPlayerViewModel>();
      await vm.initializePlayer(widget.videoUrl);
      await Future.delayed(
          const Duration(milliseconds: 250)); // Defensive delay
      if (mounted) setState(() => _canShowPlayer = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoPlayerViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.channelName),
            actions: [
              IconButton(
                icon: Icon(vm.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => vm.togglePlayPause(),
              ),
            ],
          ),
          body: _buildPlayerBody(vm),
        );
      },
    );
  }

  Widget _buildPlayerBody(VideoPlayerViewModel vm) {
    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${vm.errorMessage}', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async { 
                setState(() => _canShowPlayer = false);
                await vm.retryInitialization(widget.videoUrl);
                await Future.delayed(const Duration(milliseconds: 250));
                if (mounted) setState(() => _canShowPlayer = true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!vm.isInitialized || !_canShowPlayer || vm.controller == null) {
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
    super.dispose();
  }
}
