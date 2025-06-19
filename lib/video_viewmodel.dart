import 'package:flutter/foundation.dart';
import 'package:goodchannel/video_model.dart';
import 'package:goodchannel/video_service.dart';

class VideoViewModel extends ChangeNotifier {
  final VideoService _videoService = VideoService();
  
  PlayerState _state = const PlayerState();
  PlayerState get state => _state;

  List<VideoItem> get sampleVideos => _videoService.getSampleVideos();

  Future<void> initialize() async {
    await _videoService.initialize();
    _setupListeners();
  }

  void _setupListeners() {
    // Setup MediaKit listeners
    _videoService.mediaKitPlayer.stream.error.listen((error) {
      if (error.toString().contains('Failed to open') && !_state.usingVlcFallback) {
        _tryVlcFallback(_state.currentSource);
      }
    });

    // Setup VLC listeners
    _videoService.vlcPlayerController.addListener(() {
      final vlcValue = _videoService.vlcPlayerController.value;
      if (vlcValue.isPlaying != _state.isPlaying) {
        _updateState(_state.copyWith(isPlaying: vlcValue.isPlaying));
      }
      if (vlcValue.isBuffering != _state.isBuffering) {
        _updateState(_state.copyWith(isBuffering: vlcValue.isBuffering));
      }
    });
  }

  void _updateState(PlayerState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> playVideo(String source) async {
    _updateState(_state.copyWith(
      currentSource: source,
      isBuffering: true,
      hasError: false,
      errorMessage: null,
    ));

    try {
      await _videoService.playWithMediaKit(source);
      _updateState(_state.copyWith(
        isPlaying: true,
        isBuffering: false,
        usingVlcFallback: false,
      ));
    } catch (e) {
      debugPrint('MediaKit failed: $e');
      await _tryVlcFallback(source);
    }
  }

  Future<void> _tryVlcFallback(String source) async {
    try {
      _updateState(_state.copyWith(usingVlcFallback: true));
      await _videoService.playWithVlc(source);
      _updateState(_state.copyWith(
        isPlaying: true,
        isBuffering: false,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        hasError: true,
        errorMessage: 'Both players failed: $e',
        isPlaying: false,
        isBuffering: false,
      ));
    }
  }

  Future<void> togglePlayPause() async {
    if (_state.usingVlcFallback) {
      if (_state.isPlaying) {
        await _videoService.pauseVlc();
      } else {
        await _videoService.playVlc();
      }
    } else {
      if (_state.isPlaying) {
        await _videoService.pauseMediaKit();
      } else {
        await _videoService.playMediaKit();
      }
    }
    _updateState(_state.copyWith(isPlaying: !_state.isPlaying));
  }

  void changePlaybackSpeed() {
    double newSpeed = _state.playbackSpeed == 1.0
        ? 1.5
        : _state.playbackSpeed == 1.5
            ? 2.0
            : 0.5;

    if (_state.usingVlcFallback) {
      _videoService.setVlcSpeed(newSpeed);
    } else {
      _videoService.setMediaKitSpeed(newSpeed);
    }

    _updateState(_state.copyWith(playbackSpeed: newSpeed));
  }

  Future<void> stopPlayer() async {
    if (_state.usingVlcFallback) {
      await _videoService.stopVlc();
    } else {
      await _videoService.stopMediaKit();
    }
    _updateState(_state.copyWith(isPlaying: false));
  }

  void toggleFullscreen() {
    _updateState(_state.copyWith(isFullscreen: !_state.isFullscreen));
  }

  Future<void> pickLocalVideo() async {
    final path = await _videoService.pickLocalVideo();
    if (path != null) {
      await playVideo(path);
    }
  }

  @override
  void dispose() {
    _videoService.dispose();
    super.dispose();
  }
}