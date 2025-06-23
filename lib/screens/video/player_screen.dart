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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().initializePlayer(widget.channel.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: playerProvider.isFullScreen
              ? _buildFullScreenPlayer(playerProvider)
              : _buildNormalPlayer(playerProvider),
        );
      },
    );
  }

  Widget _buildNormalPlayer(PlayerProvider playerProvider) {
    return Column(
      children: [
        AppBar(
          title: Text(widget.channel.name),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: _buildVideoPlayer(playerProvider),
        ),
        _buildControlsPanel(playerProvider),
      ],
    );
  }

  Widget _buildFullScreenPlayer(PlayerProvider playerProvider) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      child: Stack(
        children: [
          _buildVideoPlayer(playerProvider),
          if (_showControls) _buildFullScreenControls(playerProvider),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(PlayerProvider playerProvider) {
    return Container(
      width: double.infinity,
      height: playerProvider.isFullScreen 
          ? MediaQuery.of(context).size.height 
          : 250,
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

  Widget _buildControlsPanel(PlayerProvider playerProvider) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlaybackControls(playerProvider),
          const SizedBox(height: 16),
          _buildVolumeControl(playerProvider),
          const SizedBox(height: 16),
          _buildSpeedControl(playerProvider),
          const SizedBox(height: 16),
          _buildFullScreenButton(playerProvider),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(PlayerProvider playerProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: playerProvider.stop,
          icon: const Icon(Icons.stop, color: Colors.white, size: 32),
        ),
        IconButton(
          onPressed: playerProvider.isPlaying 
              ? playerProvider.pause 
              : playerProvider.play,
          icon: Icon(
            playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 48,
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
          },
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _buildVolumeControl(PlayerProvider playerProvider) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Volume: ${playerProvider.volume.toInt()}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: playerProvider.volume,
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.grey,
          onChanged: playerProvider.setVolume,
        ),
      ],
    );
  }

  Widget _buildSpeedControl(PlayerProvider playerProvider) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.speed, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Speed: ${playerProvider.playbackSpeed.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        Slider(
          value: playerProvider.playbackSpeed,
          min: 0.25,
          max: 2.0,
          divisions: 7,
          activeColor: Colors.deepPurple,
          inactiveColor: Colors.grey,
          onChanged: playerProvider.setPlaybackSpeed,
        ),
      ],
    );
  }

  Widget _buildFullScreenButton(PlayerProvider playerProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          playerProvider.toggleFullScreen();
          if (playerProvider.isFullScreen) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          }
        },
        icon: Icon(playerProvider.isFullScreen 
            ? Icons.fullscreen_exit 
            : Icons.fullscreen),
        label: Text(playerProvider.isFullScreen 
            ? 'Exit Full Screen' 
            : 'Full Screen'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFullScreenControls(PlayerProvider playerProvider) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: playerProvider.stop,
              icon: const Icon(Icons.stop, color: Colors.white, size: 36),
            ),
            IconButton(
              onPressed: playerProvider.isPlaying 
                  ? playerProvider.pause 
                  : playerProvider.play,
              icon: Icon(
                playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
            IconButton(
              onPressed: () {
                playerProvider.toggleFullScreen();
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              },
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}