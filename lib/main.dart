import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/firebase_options.dart';
import 'package:goodchannel/provider/auth_view_model.dart';
import 'package:goodchannel/provider/channel_provider.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:goodchannel/provider/user_view_model.dart';
import 'package:goodchannel/provider/user_view_model.dart';
import 'package:goodchannel/screens/splash_screen.dart';
import 'package:goodchannel/screens/video_splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserViewModel()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
