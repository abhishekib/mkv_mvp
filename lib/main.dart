import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  // Required initialization for package:media_kit.
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player MVP',
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

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // MediaKit player objects
  late final player = Player();
  late final controller = VideoController(player);

  // Player state
  String currentSource = 'No video selected';
  bool isPlaying = false;
  bool isFullscreen = false;
  double playbackSpeed = 1.0;

  // Sample video URLs for testing
  final sampleVideos = [
    {
      'name': 'MP4 Sample (Big Buck Bunny)',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
    {
      'name': 'HLS Sample (Apple)',
      'url':
          'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
    },
    {
      'name': 'MKV Sample (Test Pattern)',
      'url': 'https://filesamples.com/samples/video/mkv/sample_1280x720.mkv',
    },
    {
      'name': 'GoodChannel Stream',
      'url': 'http://goodchannel.lol/b81855cb72/be8622a3cb0e/317187',
    },
  ];

  @override
  void initState() {
    super.initState();
    player.stream.error.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player error: $error')),
      );
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> playVideo(String source) async {
    try {
      await player.open(Media(source));
      setState(() {
        currentSource = source;
        isPlaying = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing video: $e')),
      );
    }
  }

  Future<void> pickLocalVideo() async {
    // Request storage permission
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await playVideo(path);
    }
  }

  void togglePlayPause() {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void changePlaybackSpeed() {
    setState(() {
      playbackSpeed = playbackSpeed == 1.0
          ? 1.5
          : playbackSpeed == 1.5
              ? 2.0
              : 0.5;
    });
    player.setRate(playbackSpeed);
  }

  void toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullscreen
          ? null
          : AppBar(
              title: const Text('Video Player MVP'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: toggleFullscreen,
                ),
              ],
            ),
      body: Column(
        children: [
          // Video display area
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(controller: controller),
              ),
            ),
          ),

          // Controls
          if (!isFullscreen) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentSource,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                  onPressed: () {
                    player.stop();
                    setState(() {
                      isPlaying = false;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
          ],

          // Video source selection
          if (!isFullscreen) ...[
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
                          onPressed: () => playVideo(video['url']!),
                          child: Text(video['name']!),
                        ),
                      )),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: pickLocalVideo,
                    child: const Text('Pick Local Video'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      const url = 'https://github.com/alexmercerind/media_kit';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    child: const Text('MediaKit Documentation'),
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
