import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodchannel/provider/channel_provider.dart';
import 'package:goodchannel/provider/player_provider.dart';
import 'package:goodchannel/screens/splash_screen.dart';
// import 'package:goodchannel/services/api_service.dart';
// import 'package:goodchannel/services/auth_service.dart';
// import 'package:goodchannel/viewmodels/auth_viewmodel.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

void main() async {
  // final apiService = ApiService(baseUrl: 'http://goodchannel.lol');
  // final authService = AuthService(apiService: apiService);
  // final authViewModel = AuthViewModel(authService: authService);
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          // ChangeNotifierProvider(create: (_) => authViewModel),
          // Add other providers as needed
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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
