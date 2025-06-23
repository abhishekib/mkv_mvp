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
    _isInitialized = false;
    _isPlaying = false;
    _isBuffering = false;
    _errorMessage = null;
    notifyListeners();

    // Dispose previous controller safely
    await _safeDispose();

    try {
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

    final value = _controller!.value;

    bool stateChanged = false;

    if (_isPlaying != value.isPlaying) {
      _isPlaying = value.isPlaying;
      stateChanged = true;
    }
    if (_isBuffering != value.isBuffering) {
      _isBuffering = value.isBuffering;
      stateChanged = true;
    }
    if (value.hasError && _errorMessage != value.errorDescription) {
      _errorMessage = value.errorDescription;
      stateChanged = true;
    }

    if (stateChanged) notifyListeners();
  }

  void togglePlayPause() {
    if (_controller == null) return;
    _isPlaying ? _controller!.pause() : _controller!.play();
  }

  Future<void> retryInitialization(String videoUrl) async {
    await initializePlayer(videoUrl);
  }

  Future<void> _safeDispose() async {
    try {
      if (_controller != null) {
        try {
          // Only try to dispose if _viewId exists and is not null
          final viewId = (_controller as dynamic)._viewId;
          if (viewId != null) {
            _controller?.removeListener(_playerStateListener);
            await _controller?.dispose();
          }
        } catch (e) {
          // Swallow NoSuchMethodError, it's fine
        }
        _controller = null;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _safeDispose();
    super.dispose();
  }
}
