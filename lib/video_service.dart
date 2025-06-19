import 'package:goodchannel/video_model.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  // Primary player (MediaKit)
  late final Player mediaKitPlayer;
  late final VideoController mediaKitController;

  // Fallback player (VLC)
  late final VlcPlayerController vlcPlayerController;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

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

    _isInitialized = true;
  }

  Future<void> playWithMediaKit(String source) async {
    await mediaKitPlayer.open(Media(source));
  }

  Future<void> playWithVlc(String source) async {
    await vlcPlayerController.setMediaFromNetwork(source);
    await vlcPlayerController.play();
  }

  Future<void> pauseMediaKit() async {
    await mediaKitPlayer.pause();
  }

  Future<void> pauseVlc() async {
    await vlcPlayerController.pause();
  }

  Future<void> playMediaKit() async {
    await mediaKitPlayer.play();
  }

  Future<void> playVlc() async {
    await vlcPlayerController.play();
  }

  Future<void> stopMediaKit() async {
    await mediaKitPlayer.stop();
  }

  Future<void> stopVlc() async {
    await vlcPlayerController.stop();
  }

  void setMediaKitSpeed(double speed) {
    mediaKitPlayer.setRate(speed);
  }

  void setVlcSpeed(double speed) {
    vlcPlayerController.setPlaybackSpeed(speed);
  }

  Future<String?> pickLocalVideo() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return null;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    return result?.files.single.path;
  }

  List<VideoItem> getSampleVideos() {
    return [
      VideoItem(
        name: 'MP4 Sample (Big Buck Bunny)',
        url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        type: VideoType.remote,
      ),
      VideoItem(
        name: 'GoodChannel HTTP Stream',
        url: 'http://goodchannel.lol/b81855cb72/be8622a3cb0e/317187',
        isHttp: true,
        type: VideoType.stream,
      ),
      VideoItem(
        name: 'HLS Sample (Apple)',
        url: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
        type: VideoType.stream,
      ),
    ];
  }

  void dispose() {
    if (_isInitialized) {
      mediaKitPlayer.dispose();
      vlcPlayerController.dispose();
      _isInitialized = false;
    }
  }
}