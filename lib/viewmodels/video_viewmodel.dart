// viewmodels/video_player_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VideoPlayerViewModel extends ChangeNotifier {
  VlcPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  String? get errorMessage => _errorMessage;
  VlcPlayerController? get controller => _controller;

  Future<void> initializePlayer(String videoUrl) async {
    try {
      // Clean up existing controller if any
      if (_controller != null) {
        _controller!.dispose();
      }

      _controller = VlcPlayerController.network(
        videoUrl,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(3000),
          ]),
        ),
      );

      _controller!.addListener(_playerStateListener);

      await _controller!.initialize();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isInitialized = false;
    }
    notifyListeners();
  }

  void _playerStateListener() {
    if (_controller == null) return;

    _isPlaying = _controller!.value.isPlaying;
    _isBuffering = _controller!.value.isBuffering;

    if (_controller!.value.hasError) {
      _errorMessage = _controller!.value.errorDescription;
    }
    notifyListeners();
  }

  void togglePlayPause() {
    if (_controller == null) return;
    _isPlaying ? _controller!.pause() : _controller!.play();
  }

  Future<void> retryInitialization(String videoUrl) async {
    _isInitialized = false;
    _errorMessage = null;
    notifyListeners();
    await initializePlayer(videoUrl);
  }

  void dispose() {
    _controller?.removeListener(_playerStateListener);
    _controller?.dispose();
    super.dispose();
  }
}
