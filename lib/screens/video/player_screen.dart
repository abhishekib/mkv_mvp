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
  Timer? _hideControlsTimer;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Animation controllers
  late AnimationController _controlsAnimationController;
  late AnimationController _newsTickerController;
  late Animation<double> _controlsAnimation;

  // News ticker texts
  final List<String> _newsTexts = [
    'Breaking News • Live Coverage • Stay Updated',
    'Live Broadcast • Real-time Updates • News as it Happens',
    'Latest News • Breaking Stories • Live from the Newsroom',
    'Breaking • Live Updates • News Alert • Stay Informed',
  ];
  int _currentNewsIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePlayer();
    _startHideControlsTimer();
    _startClockTimer();
    _startNewsTickerAnimation();
    _setFullScreenMode();
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _newsTickerController = AnimationController(
      duration: const Duration(seconds: 15),
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

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  void _startNewsTickerAnimation() {
    _newsTickerController.repeat();

    // Change news text every 15 seconds
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _currentNewsIndex = (_currentNewsIndex + 1) % _newsTexts.length;
        });
      }
    });
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
    _clockTimer?.cancel();
    _controlsAnimationController.dispose();
    _newsTickerController.dispose();
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
        _buildDynamicNewsChannelOverlay(playerProvider),
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
            child: CircularProgressIndicator(color: Colors.red),
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

  Widget _buildDynamicNewsChannelOverlay(PlayerProvider playerProvider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: _showControls ? 140 : 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showControls ? 50 : 30,
              color: const Color(0xFF2a2a2a),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Dynamic time display
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _showControls ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      child: Text(
                        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                      ),
                    ),
                    if (_showControls &&
                        playerProvider.duration.inSeconds > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Duration: ${_formatDuration(playerProvider.duration)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Position: ${_formatDuration(playerProvider.position)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Animated status icons
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        children: [
                          AnimatedScale(
                            scale: _showControls ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              playerProvider.isPlaying
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: _showControls ? 18 : 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedScale(
                            scale: _showControls ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.closed_caption,
                              color: Colors.white,
                              size: _showControls ? 18 : 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedScale(
                            scale: _showControls ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.hd,
                              color: Colors.white,
                              size: _showControls ? 18 : 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedScale(
                            scale: _showControls ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: _showControls ? 18 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(PlayerProvider playerProvider) {
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
                // Animated top control bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: _controlsAnimation.value,
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedSlide(
                          offset: Offset(0, 1 - _controlsAnimation.value),
                          duration: const Duration(milliseconds: 300),
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
                      ),
                      // Animated top right controls
                      AnimatedScale(
                        scale: _controlsAnimation.value,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedScale(
                        scale: _controlsAnimation.value,
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Animated center play controls
                if (!playerProvider.isBuffering)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 160),
                    child: AnimatedScale(
                      scale: _controlsAnimation.value,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimatedControlButton(
                            Icons.replay_10,
                            () {
                              _seekRelative(playerProvider, -10);
                              _startHideControlsTimer();
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildAnimatedControlButton(
                            playerProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            () {
                              playerProvider.isPlaying
                                  ? playerProvider.pause()
                                  : playerProvider.play();
                              _startHideControlsTimer();
                            },
                            isMain: true,
                          ),
                          const SizedBox(width: 24),
                          _buildAnimatedControlButton(
                            Icons.forward_10,
                            () {
                              _seekRelative(playerProvider, 10);
                              _startHideControlsTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedControlButton(IconData icon, VoidCallback onPressed,
      {bool isMain = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isMain ? 64 : 48,
      height: isMain ? 64 : 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(isMain ? 32 : 24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMain ? 32 : 24),
          onTap: onPressed,
          child: Icon(
            icon,
            color: Colors.white,
            size: isMain ? 32 : 24,
          ),
        ),
      ),
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
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
