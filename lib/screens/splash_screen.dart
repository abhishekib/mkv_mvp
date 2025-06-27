import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goodchannel/screens/login_screen.dart';
import 'package:goodchannel/widgets/dotted_circular_progress.dart';
import 'package:goodchannel/widgets/utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _colorCycleController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorCycleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _colorCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Utils.getScreenGradient(),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 210.0),
                      child: SizedBox(
                        height: 400,
                        width: 800,
                        child: Image.asset('assets/text_icon.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: AnimatedBuilder(
                          animation: _colorCycleController,
                          builder: (context, child) {
                            return DottedCircularProgress(
                              progress: 1.0,
                              dotCount: 10,
                              dotSize: 10,
                              gapSize: 4,
                              cycleValue: _colorCycleController.value,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

