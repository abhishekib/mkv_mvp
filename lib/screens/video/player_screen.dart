import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:goodchannel/models/channel_model.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:provider/provider.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  bool _showControls = true;
  bool _isInitializing = true;
  bool _showVolumeSlider = false;
  Timer? _hideControlsTimer;
  Timer? _hideVolumeSliderTimer;
  double _maxPosition = 1.0;

  // Animation controllers
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePlayer();
    _startHideControlsTimer();
    _setFullScreenMode();
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    _controlsAnimationController.forward();
  }

  void _setFullScreenMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.forward();
        _startHideControlsTimer();
      } else {
        _controlsAnimationController.reverse();
      }
    });
  }

  void _toggleVolumeSlider() {
    setState(() {
      _showVolumeSlider = !_showVolumeSlider;
      if (_showVolumeSlider) {
        _hideVolumeSliderTimer?.cancel();
        _hideVolumeSliderTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _showVolumeSlider = false);
          }
        });
      }
    });
  }

  void _startVolumeSliderTimer() {
    _hideVolumeSliderTimer?.cancel();
    _hideVolumeSliderTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showVolumeSlider) {
        setState(() => _showVolumeSlider = false);
      }
    });
  }

  void _cancelVolumeSliderTimer() {
    _hideVolumeSliderTimer?.cancel();
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
    _hideVolumeSliderTimer?.cancel();
    _controlsAnimationController.dispose();
    _restorePortraitOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isInitializing
        ? const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          )
        : Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              // Update max position for live streams
              if (playerProvider.position.inSeconds > _maxPosition) {
                _maxPosition = playerProvider.position.inSeconds.toDouble();
              }
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
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializePlayer(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        _buildVideoPlayer(playerProvider),
        if (_showVolumeSlider) buildVolumeSlider(playerProvider),
        AnimatedBuilder(
          animation: _controlsAnimation,
          builder: (context, child) {
            return _showControls || playerProvider.isBuffering
                ? _buildControlsOverlay(playerProvider)
                : const SizedBox.shrink();
          },
        ),
        if (playerProvider.isBuffering)
          const Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(PlayerProvider playerProvider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleControlsVisibility,
      child: SizedBox.expand(
        child: playerProvider.controller != null
            ? VlcPlayer(
                controller: playerProvider.controller!,
                aspectRatio: 16 / 9,
                placeholder: const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
      ),
    );
  }

  Widget buildVolumeSlider(PlayerProvider playerProvider) {
    return Positioned(
      right: 70,
      bottom: 100,
      child: Container(
        width: 50,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.deepPurpleAccent,
            inactiveTrackColor: Colors.grey[600],
            thumbColor: Colors.deepPurpleAccent,
            overlayColor: Colors.deepPurpleAccent.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
              disabledThumbRadius: 6,
            ),
            trackHeight: 6,
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: playerProvider.volume.clamp(0.0, 100.0),
              min: 0,
              max: 100,
              divisions: 100,
              label: '${playerProvider.volume.round()}%',
              onChanged: (value) async {
                await playerProvider.setVolume(value);
              },
              onChangeStart: (_) => _cancelVolumeSliderTimer(),
              onChangeEnd: (_) => _startVolumeSliderTimer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(PlayerProvider playerProvider) {
    final bool isLiveStream = playerProvider.duration.inSeconds <= 0;

    return AnimatedBuilder(
      animation: _controlsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _controlsAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7 * _controlsAnimation.value),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.3 * _controlsAnimation.value),
                ],
              ),
            ),
            child: Column(
              children: [
                // Top control bar
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.channel.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Live Broadcast • ${widget.channel.group}',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bottom controls
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Play/pause button
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        height: 35,
                        width: 35,
                        child: IconButton(
                          icon: Icon(
                            playerProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                            playerProvider.isPlaying
                                ? playerProvider.pause()
                                : playerProvider.play();
                            _startHideControlsTimer();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Current time
                      Text(
                        _formatDuration(playerProvider.position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Progress bar - always show for both live and VOD
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.deepPurpleAccent,
                            inactiveTrackColor: Colors.grey[600],
                            thumbColor: Colors.deepPurpleAccent,
                            overlayColor: Colors.red.withOpacity(0.2),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: playerProvider.position.inSeconds.toDouble(),
                            min: 0,
                            max: isLiveStream
                                ? (_maxPosition > 0 ? _maxPosition : 1.0)
                                : playerProvider.duration.inSeconds.toDouble(),
                            onChanged: isLiveStream
                                ? null // Disable seeking for live streams
                                : (value) {
                                    playerProvider.seekTo(
                                        Duration(seconds: value.toInt()));
                                    _startHideControlsTimer();
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Duration or LIVE indicator
                      if (isLiveStream)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Text(
                          _formatDuration(playerProvider.duration),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(width: 16),
                      // Volume button
                      IconButton(
                        icon: Icon(
                          playerProvider.volume > 0
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          _toggleVolumeSlider();
                          _startHideControlsTimer();
                        },
                      ),
                      const SizedBox(width: 8),
                      // Fullscreen button
                      IconButton(
                        icon: const Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _restorePortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
