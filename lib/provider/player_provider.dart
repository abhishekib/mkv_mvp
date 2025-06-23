import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class PlayerProvider with ChangeNotifier {
  VlcPlayerController? _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  double _volume = 50.0;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  VlcPlayerController? get controller => _controller;
  bool get isPlaying => _isPlaying;
  bool get isFullScreen => _isFullScreen;
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;

  void initializePlayer(String url) {
    _controller = VlcPlayerController.network(
      url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        video: VlcVideoOptions([
          VlcVideoOptions.dropLateFrames(true),
          VlcVideoOptions.skipFrames(true),
        ]),
        // audio: VlcAudioOptions([
        //   VlcAudioOptions.audioTimeStretchAlgorithm(VlcAudioOptions.audioTimeStretchAlgorithmSonic),
        // ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );

    _controller?.addOnInitListener(() {
      _isPlaying = true;
      notifyListeners();
    });

    // _controller?.addOnPositionChangedListener((position) {
    //   _position = position;
    //   notifyListeners();
    // });

    // _controller?.addOnDurationChangedListener((duration) {
    //   _duration = duration;
    //   notifyListeners();
    // });
  }

  void play() {
    _controller?.play();
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _controller?.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void stop() {
    _controller?.stop();
    _isPlaying = false;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume;
    _controller?.setVolume(volume.toInt());
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _controller?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  void seekTo(Duration position) {
    _controller?.seekTo(position);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
