import 'dart:math';
import 'package:flutter/material.dart';

/// A living gradient background: soft drifting clouds and/or
/// twinkling stars, painted once per frame by a single CustomPainter
/// so it stays buttery smooth even on modest phones.
class AnimatedSkyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool showClouds;
  final bool showStars;
  final Widget? child;

  const AnimatedSkyBackground({
    super.key,
    required this.gradientColors,
    this.showClouds = true,
    this.showStars = false,
    this.child,
  });

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.gradientColors,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SkyPainter(
                    progress: _controller.value,
                    showClouds: widget.showClouds,
                    showStars: widget.showStars,
                  ),
                );
              },
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double progress;
  final bool showClouds;
  final bool showStars;

  _SkyPainter({
    required this.progress,
    required this.showClouds,
    required this.showStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showStars) {
      final starPaint = Paint()..color = Colors.white;
      for (int i = 0; i < 45; i++) {
        final rand = Random(i * 97);
        final dx = rand.nextDouble() * size.width;
        final dy = rand.nextDouble() * size.height * 0.65;
        final twinkle = (sin(progress * 2 * pi * 2 + i) + 1) / 2;
        starPaint.color = Colors.white.withValues(alpha: 0.25 + twinkle * 0.75);
        canvas.drawCircle(Offset(dx, dy), 1.0 + (i % 3) * 0.6, starPaint);
      }
    }
    if (showClouds) {
      final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
      for (int i = 0; i < 4; i++) {
        final rand = Random(i * 13 + 5);
        final speed = 0.3 + rand.nextDouble() * 0.5;
        final top = size.height * (0.08 + rand.nextDouble() * 0.3);
        final scale = 0.7 + rand.nextDouble() * 0.7;
        final startOffset = rand.nextDouble();
        final t = (progress * speed + startOffset) % 1.0;
        final x = -180 + t * (size.width + 360);
        _drawCloud(canvas, Offset(x, top), scale, cloudPaint);
      }
    }
  }

  void _drawCloud(Canvas canvas, Offset pos, double scale, Paint paint) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale);
    canvas.drawCircle(const Offset(20, 20), 18, paint);
    canvas.drawCircle(const Offset(45, 10), 22, paint);
    canvas.drawCircle(const Offset(75, 20), 16, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 15, 80, 20),
        const Radius.circular(14),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
