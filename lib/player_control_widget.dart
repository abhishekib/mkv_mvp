import 'package:flutter/material.dart';
import 'package:goodchannel/video_model.dart';

class PlayerControlsWidget extends StatelessWidget {
  final PlayerState state;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onSpeedChange;
  final VoidCallback onFullscreen;

  const PlayerControlsWidget({
    super.key,
    required this.state,
    required this.onPlayPause,
    required this.onStop,
    required this.onSpeedChange,
    required this.onFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current source info
          _buildSourceInfo(),
          const SizedBox(height: 16),
          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildSourceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.video_file,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.currentSource,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (state.usingVlcFallback) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Using VLC fallback',
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Play/Pause button
        _buildControlButton(
          icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
          label: state.isPlaying ? 'Pause' : 'Play',
          onPressed: onPlayPause,
          color: Colors.blue,
        ),

        // Speed control button
        _buildControlButton(
          icon: Icons.speed,
          label: '${state.playbackSpeed}x',
          onPressed: onSpeedChange,
          color: Colors.green,
        ),

        // Stop button
        _buildControlButton(
          icon: Icons.stop,
          label: 'Stop',
          onPressed: onStop,
          color: Colors.red,
        ),

        // Fullscreen button
        _buildControlButton(
          icon: state.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
          label: 'Fullscreen',
          onPressed: onFullscreen,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
            iconSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
