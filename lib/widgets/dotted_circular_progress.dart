import 'dart:math';
import 'package:flutter/material.dart';

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
          Colors.deepPurpleAccent,
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
