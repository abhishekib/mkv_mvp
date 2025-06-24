import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class PlayerProvider with ChangeNotifier {
  VlcPlayerController? _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _isBuffering = false;
  double _volume = 50.0;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _currentUrl;
  String? _error;

  VlcPlayerController? get controller => _controller;
  bool get isPlaying => _isPlaying;
  bool get isFullScreen => _isFullScreen;
  bool get isBuffering => _isBuffering;
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get currentUrl => _currentUrl;
  String? get error => _error;

  Future<void> initializePlayer(String url) async {
    try {
      await safeDispose();
      _currentUrl = url;
      _error = null;
      _isBuffering = true;
      _position = Duration.zero; // Reset position
      _duration = Duration.zero; // Reset duration
      notifyListeners();

      _controller = VlcPlayerController.network(
        url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(5000),
            VlcAdvancedOptions.clockJitter(3000),
          ]),
          http: VlcHttpOptions([
            VlcHttpOptions.httpReconnect(true),
          ]),
          video: VlcVideoOptions([
            VlcVideoOptions.dropLateFrames(true),
            VlcVideoOptions.skipFrames(true),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );
      _setupControllerListeners();
    } catch (e) {
      _error = 'Failed to initialize player: $e';
      _isPlaying = false;
      _isBuffering = false;
      notifyListeners();
    }
  }

  void _setupControllerListeners() {
    _controller?.addListener(_updatePlayerState);
  }

  Future<void> play() async {
    try {
      await _controller?.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to play: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _controller?.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to pause: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _controller?.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 100.0);
    _volume = clampedVolume;
    try {
      await _controller?.setVolume(clampedVolume.round()); // VLC expects 0-100
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set volume: $e';
      notifyListeners();
    }
  }

  void setVolumeSync(double volume) {
    _volume = volume.clamp(0.0, 100.0);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    try {
      await _controller?.setPlaybackSpeed(speed);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to set playback speed: $e';
      notifyListeners();
    }
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _controller?.seekTo(position);
      _position = position;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to seek: $e';
      notifyListeners();
    }
  }

  Future<void> disposeController() async {
    await _controller?.dispose();
    _controller = null;
    _isPlaying = false;
    _isBuffering = false;
  }

  void _updatePlayerState() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final value = _controller!.value;
    _isBuffering = value.isBuffering;
    _isPlaying = value.isPlaying;
    _position = value.position;
    _duration = value.duration;

    if (value.hasError) {
      _error = value.errorDescription;
      _isPlaying = false;
      _isBuffering = false;
    }

    notifyListeners();
  }

  Future<void> safeDispose() async {
    if (_controller != null) {
      _controller?.removeListener(_updatePlayerState);
      await _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }
}
