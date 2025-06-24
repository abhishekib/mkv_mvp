import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:goodchannel/models/channel_model.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:provider/provider.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({Key? key, required this.channel}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _showControls = true;
  bool _isInitializing = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideControlsTimer();
      }
    });
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isInitializing = true);
      await context.read<PlayerProvider>().initializePlayer(widget.channel.url);
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitializing
        ? const Center(child: CircularProgressIndicator())
        : Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: _buildPlayerBody(playerProvider),
              );
            },
          );
  }

  Widget _buildPlayerBody(PlayerProvider playerProvider) {
    if (playerProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              playerProvider.error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializePlayer(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildVideoPlayer(playerProvider),
        if (_showControls || playerProvider.isBuffering)
          _buildControlsOverlay(playerProvider),
        if (playerProvider.isBuffering)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(PlayerProvider playerProvider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControlsVisibility,
      child: playerProvider.controller != null
          ? VlcPlayer(
              controller: playerProvider.controller!,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Widget _buildControlsOverlay(PlayerProvider playerProvider) {
    return IgnorePointer(
      ignoring: !_showControls,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (playerProvider.isFullScreen) {
                      playerProvider.toggleFullScreen();
                      _restorePortraitOrientation();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  widget.channel.name,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              if (!playerProvider.isBuffering)
                _buildPlayerControls(playerProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerControls(PlayerProvider playerProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProgressBar(playerProvider),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.replay_10, color: Colors.white, size: 30),
                onPressed: () {
                  _seekRelative(playerProvider, -10);
                  _startHideControlsTimer(); // Reset timer on interaction
                },
              ),
              IconButton(
                icon: Icon(
                  playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  playerProvider.isPlaying
                      ? playerProvider.pause()
                      : playerProvider.play();
                  _startHideControlsTimer(); // Reset timer on interaction
                },
              ),
              IconButton(
                icon:
                    const Icon(Icons.forward_10, color: Colors.white, size: 30),
                onPressed: () {
                  _seekRelative(playerProvider, 10);
                  _startHideControlsTimer(); // Reset timer on interaction
                },
              ),
              IconButton(
                icon: Icon(
                  playerProvider.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  playerProvider.toggleFullScreen();
                  if (playerProvider.isFullScreen) {
                    SystemChrome.setPreferredOrientations([
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);
                    SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersiveSticky);
                  } else {
                    _restorePortraitOrientation();
                  }
                  _startHideControlsTimer(); // Reset timer on interaction
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PlayerProvider playerProvider) {
    if (playerProvider.duration.inSeconds <= 0) {
      return const SizedBox();
    }

    return Column(
      children: [
        Slider(
          value: playerProvider.position.inSeconds.toDouble().clamp(
                0.0,
                playerProvider.duration.inSeconds.toDouble(),
              ),
          min: 0.0,
          max: playerProvider.duration.inSeconds.toDouble(),
          onChanged: (value) {
            playerProvider.seekTo(Duration(seconds: value.toInt()));
            _startHideControlsTimer(); // Reset timer on interaction
          },
          onChangeEnd: (value) {
            playerProvider.seekTo(Duration(seconds: value.toInt()));
            _startHideControlsTimer(); // Reset timer on interaction
          },
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.grey[600],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(playerProvider.position),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _formatDuration(playerProvider.duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  Future<void> _seekRelative(PlayerProvider playerProvider, int seconds) async {
    final newPosition = playerProvider.position + Duration(seconds: seconds);
    await playerProvider.seekTo(newPosition);
  }

  void _restorePortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
