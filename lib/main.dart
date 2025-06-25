import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/provider/channel_provider.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:goodchannel/screens/splash_screen.dart';
import 'package:goodchannel/screens/video_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ChannelProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VideoSplashScreen(nextScreen: SplashScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
