import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:goodchannel/screens/login_screen.dart';
import 'package:goodchannel/screens/sign_up_screen.dart';
import 'package:goodchannel/screens/video_player_screen.dart';

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
        MaterialPageRoute(builder: (context) => SignUpScreen()),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF303F9F),
            ],
          ),
        ),
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

class DottedCircularProgress extends StatelessWidget {
  final double progress;
  final int dotCount;
  final double dotSize;
  final double gapSize;
  final double cycleValue;

  const DottedCircularProgress({
    super.key,
    required this.progress,
    this.dotCount = 20,
    this.dotSize = 8.0,
    this.gapSize = 4.0,
    required this.cycleValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedCircularProgressPainter(
        progress: progress,
        dotCount: dotCount,
        dotSize: dotSize,
        gapSize: gapSize,
        cycleValue: cycleValue,
      ),
    );
  }
}

class _DottedCircularProgressPainter extends CustomPainter {
  final double progress;
  final int dotCount;
  final double dotSize;
  final double gapSize;
  final double cycleValue;

  _DottedCircularProgressPainter({
    required this.progress,
    required this.dotCount,
    required this.dotSize,
    required this.gapSize,
    required this.cycleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - dotSize / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    final totalAngle = 2 * pi;
    final anglePerDot = totalAngle / dotCount;

    for (int i = 0; i < dotCount; i++) {
      final angle = -pi / 2 + i * anglePerDot;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);

      // Calculate color based on position and cycleValue
      final dotPosition = i / dotCount;
      final cyclePosition = (dotPosition + cycleValue) % 1.0;

      if (cyclePosition < 0.5) {
        // Active (white to purple gradient)
        final intensity = 1.0 - (cyclePosition * 2);
        paint.color = Color.lerp(
          Colors.white,
          Colors.black,
          intensity,
        )!;
      } else {
        // Inactive (gray)
        paint.color = Colors.grey[300]!;
      }

      canvas.drawCircle(Offset(dotX, dotY), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
