import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player with VLC Fallback',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VideoPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class VideoItem {
  final String name;
  final String url;
  final bool isHttp;

  VideoItem({
    required this.name,
    required this.url,
    this.isHttp = false,
  });
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Primary player (MediaKit)
  late final Player mediaKitPlayer;
  late final VideoController mediaKitController;

  // Fallback player (VLC)
  late final VlcPlayerController vlcPlayerController;

  // Player state
  String currentSource = 'No video selected';
  bool isPlaying = false;
  bool isFullscreen = false;
  double playbackSpeed = 1.0;
  bool usingVlcFallback = false;
  bool isBuffering = false;

  final List<VideoItem> sampleVideos = [
    VideoItem(
      name: 'MP4 Sample (Big Buck Bunny)',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    VideoItem(
      name: 'GoodChannel HTTP Stream',
      url: 'http://goodchannel.lol/b81855cb72/be8622a3cb0e/317187',
      isHttp: true,
    ),
    VideoItem(
      name: 'HLS Sample (Apple)',
      url:
          'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize MediaKit player
    mediaKitPlayer = Player();
    mediaKitController = VideoController(mediaKitPlayer);

    // Initialize VLC player
    vlcPlayerController = VlcPlayerController.network(
      '',
      hwAcc: HwAcc.full,
      autoInitialize: false,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(3000),
        ]),
      ),
    );

    // Setup listeners
    mediaKitPlayer.stream.error.listen((error) {
      if (error.toString().contains('Failed to open') && !usingVlcFallback) {
        _tryVlcFallback(currentSource);
      }
    });

    vlcPlayerController.addListener(() {
      if (vlcPlayerController.value.isPlaying != isPlaying) {
        setState(() => isPlaying = vlcPlayerController.value.isPlaying);
      }
      if (vlcPlayerController.value.isBuffering != isBuffering) {
        setState(() => isBuffering = vlcPlayerController.value.isBuffering);
      }
    });
  }

  @override
  void dispose() {
    mediaKitPlayer.dispose();
    vlcPlayerController.dispose();
    super.dispose();
  }

  Future<void> playVideo(String source) async {
    setState(() {
      currentSource = source;
      isBuffering = true;
    });

    try {
      // First try with MediaKit
      await _playWithMediaKit(source);
      setState(() => usingVlcFallback = false);
    } catch (e) {
      debugPrint('MediaKit failed: $e');
      // Fallback to VLC if MediaKit fails
      await _tryVlcFallback(source);
    }
  }

  Future<void> _playWithMediaKit(String source) async {
    await mediaKitPlayer.open(Media(source));
    setState(() {
      isPlaying = true;
      isBuffering = false;
    });
  }

  Future<void> _tryVlcFallback(String source) async {
    try {
      setState(() => usingVlcFallback = true);
      await vlcPlayerController.setMediaFromNetwork(source);
      await vlcPlayerController.play();
      setState(() {
        isPlaying = true;
        isBuffering = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Using VLC fallback player')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('VLC fallback also failed: $e')),
      );
      setState(() {
        isPlaying = false;
        isBuffering = false;
      });
    }
  }

  Future<void> pickLocalVideo() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      await playVideo(result.files.single.path!);
    }
  }

  void togglePlayPause() {
    if (usingVlcFallback) {
      if (isPlaying) {
        vlcPlayerController.pause();
      } else {
        vlcPlayerController.play();
      }
    } else {
      if (isPlaying) {
        mediaKitPlayer.pause();
      } else {
        mediaKitPlayer.play();
      }
    }
    setState(() => isPlaying = !isPlaying);
  }

  void changePlaybackSpeed() {
    setState(() {
      playbackSpeed = playbackSpeed == 1.0
          ? 1.5
          : playbackSpeed == 1.5
              ? 2.0
              : 0.5;
    });

    if (usingVlcFallback) {
      // VLC uses different method for playback speed
      vlcPlayerController.setPlaybackSpeed(playbackSpeed);
    } else {
      mediaKitPlayer.setRate(playbackSpeed);
    }
  }

  void stopPlayer() {
    if (usingVlcFallback) {
      vlcPlayerController.stop();
    } else {
      mediaKitPlayer.stop();
    }
    setState(() => isPlaying = false);
  }

  void toggleFullscreen() {
    setState(() => isFullscreen = !isFullscreen);
  }

  Widget _buildVideoPlayer() {
    if (usingVlcFallback) {
      return VlcPlayer(
        controller: vlcPlayerController,
        aspectRatio: 16 / 9,
        placeholder: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isBuffering) const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text('VLC Player'),
              if (isBuffering) const Text('Buffering...'),
            ],
          ),
        ),
      );
    } else {
      return Video(
        controller: mediaKitController,
        controls: (state) => MaterialVideoControls(
          state,
          // seekOnDoubleTap: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullscreen
          ? null
          : AppBar(
              title: const Text('Video Player with VLC Fallback'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: toggleFullscreen,
                ),
              ],
            ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildVideoPlayer(),
              ),
            ),
          ),
          if (!isFullscreen) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSource,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usingVlcFallback)
                    const Text('Using VLC fallback',
                        style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: togglePlayPause,
                ),
                IconButton(
                  icon: Text('${playbackSpeed}x'),
                  onPressed: changePlaybackSpeed,
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: stopPlayer,
                ),
              ],
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sample Videos:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...sampleVideos.map((video) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ElevatedButton(
                          onPressed: () => playVideo(video.url),
                          child: Text(video.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: video.isHttp
                                ? Colors.orange.withOpacity(0.2)
                                : null,
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: pickLocalVideo,
                    child: const Text('Pick Local Video'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
