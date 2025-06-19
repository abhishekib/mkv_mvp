import 'package:flutter/material.dart';
import 'package:goodchannel/player_control_widget.dart';
import 'package:goodchannel/video_list_widget.dart';
import 'package:goodchannel/video_player_widget.dart';
import 'package:goodchannel/video_service.dart';
import 'package:goodchannel/video_viewmodel.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoViewModel _viewModel;
  final VideoService _videoService = VideoService();

  @override
  void initState() {
    super.initState();
    _viewModel = VideoViewModel();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _viewModel.initialize();
    setState(() {}); // Trigger rebuild after initialization
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _viewModel.state.isFullscreen
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              title: const Row(
                children: [
                  Icon(Icons.video_library, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Good Channel Player',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _viewModel.state.isFullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                  ),
                  onPressed: () {
                    _viewModel.toggleFullscreen();
                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.state.isFullscreen) {
            return _buildFullscreenView();
          }
          return _buildNormalView();
        },
      ),
    );
  }

  Widget _buildFullscreenView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: VideoPlayerWidget(
          state: _viewModel.state,
          videoService: _videoService,
        ),
      ),
    );
  }

  Widget _buildNormalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Player Section
          _buildPlayerSection(),

          const SizedBox(height: 24),

          // Player Controls Section
          _buildControlsSection(),

          const SizedBox(height: 24),

          // Video List Section
          _buildVideoListSection(),
        ],
      ),
    );
  }

  Widget _buildPlayerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle_filled,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Video Player',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_viewModel.state.isBuffering)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          VideoPlayerWidget(
            state: _viewModel.state,
            videoService: _videoService,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return PlayerControlsWidget(
      state: _viewModel.state,
      onPlayPause: () {
        _viewModel.togglePlayPause();
        setState(() {});
      },
      onStop: () {
        _viewModel.stopPlayer();
        setState(() {});
      },
      onSpeedChange: () {
        _viewModel.changePlaybackSpeed();
        setState(() {});
      },
      onFullscreen: () {
        _viewModel.toggleFullscreen();
        setState(() {});
      },
    );
  }

  Widget _buildVideoListSection() {
    return VideoListWidget(
      videos: _viewModel.sampleVideos,
      onVideoSelected: (url) {
        _viewModel.playVideo(url);
        setState(() {});

        // Show snackbar for feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loading video...'),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      onPickLocalVideo: () {
        _viewModel.pickLocalVideo();
        setState(() {});
      },
    );
  }
}
