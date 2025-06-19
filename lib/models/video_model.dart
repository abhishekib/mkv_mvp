class VideoItem {
  final String name;
  final String url;
  final bool isHttp;
  final VideoType type;

  VideoItem({
    required this.name,
    required this.url,
    this.isHttp = false,
    this.type = VideoType.remote,
  });
}

enum VideoType {
  remote,
  local,
  stream,
}

class PlayerState {
  final String currentSource;
  final bool isPlaying;
  final bool isFullscreen;
  final double playbackSpeed;
  final bool usingVlcFallback;
  final bool isBuffering;
  final bool hasError;
  final String? errorMessage;

  const PlayerState({
    this.currentSource = 'No video selected',
    this.isPlaying = false,
    this.isFullscreen = false,
    this.playbackSpeed = 1.0,
    this.usingVlcFallback = false,
    this.isBuffering = false,
    this.hasError = false,
    this.errorMessage,
  });

  PlayerState copyWith({
    String? currentSource,
    bool? isPlaying,
    bool? isFullscreen,
    double? playbackSpeed,
    bool? usingVlcFallback,
    bool? isBuffering,
    bool? hasError,
    String? errorMessage,
  }) {
    return PlayerState(
      currentSource: currentSource ?? this.currentSource,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      usingVlcFallback: usingVlcFallback ?? this.usingVlcFallback,
      isBuffering: isBuffering ?? this.isBuffering,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
