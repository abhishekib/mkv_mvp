import 'package:flutter/material.dart';
import 'package:goodchannel/models/video_model.dart';
import 'package:goodchannel/services/video_service.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final PlayerState state;
  final VideoService videoService;

  const VideoPlayerWidget({
    super.key,
    required this.state,
    required this.videoService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildPlayer(),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (state.usingVlcFallback) {
      return VlcPlayer(
        controller: videoService.vlcPlayerController,
        aspectRatio: 16 / 9,
        placeholder: _buildPlaceholder(isVlc: true),
      );
    } else {
      return Video(
        controller: videoService.mediaKitController,
        controls: (state) => MaterialVideoControls(state),
      );
    }
  }

  Widget _buildPlaceholder({bool isVlc = false}) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.isBuffering)
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            const SizedBox(height: 16),
            Icon(
              isVlc ? Icons.video_library : Icons.play_circle_outline,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isVlc ? 'VLC Player' : 'MediaKit Player',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state.isBuffering)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Buffering...',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${state.errorMessage}',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
