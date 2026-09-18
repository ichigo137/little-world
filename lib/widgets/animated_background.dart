import 'dart:math';
import 'package:flutter/material.dart';

/// A living gradient background: drifting parallax clouds, twinkling
/// stars, soft aurora glows, wandering fireflies and the occasional
/// shooting star — all painted by a single CustomPainter per frame so
/// it stays buttery smooth even on modest phones.
///
/// Every spec (star, cloud, firefly) is generated ONCE in state and
/// passed into the painter, so no per-frame allocations happen.
class AnimatedSkyBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final bool showClouds;
  final bool showStars;
  final bool showAurora;
  final bool showFireflies;
  final Widget? child;

  const AnimatedSkyBackground({
    super.key,
    required this.gradientColors,
    this.showClouds = true,
    this.showStars = false,
    this.showAurora = false,
    this.showFireflies = false,
    this.child,
  });

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_StarSpec> _stars;
  late final List<_CloudSpec> _clouds;
  late final List<_FireflySpec> _fireflies;
  late final List<_ShootingStarSpec> _shootingStars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    final rand = Random(7);

    _stars = List.generate(70, (i) {
      return _StarSpec(
        dx: rand.nextDouble(),
        dy: rand.nextDouble() * 0.62,
        radius: 0.5 + rand.nextDouble() * 1.3,
        phase: rand.nextDouble() * 2 * pi,
        speedHz: 0.15 + rand.nextDouble() * 0.35,
      );
    });

    _shootingStars = [
      const _ShootingStarSpec(
          t0: 0.13, t1: 0.145, sx: 0.85, sy: 0.08, ex: 0.25, ey: 0.38),
      const _ShootingStarSpec(
          t0: 0.58, t1: 0.595, sx: 0.15, sy: 0.12, ex: 0.75, ey: 0.42),
    ];

    // Three parallax depth layers: far & faint → near & bright.
    _clouds = [];
    const layers = [
      (count: 3, speed: 0.22, top: 0.04, scale: 0.55, alpha: 0.05),
      (count: 2, speed: 0.38, top: 0.16, scale: 0.85, alpha: 0.09),
      (count: 2, speed: 0.55, top: 0.28, scale: 1.25, alpha: 0.13),
    ];
    for (final layer in layers) {
      for (int i = 0; i < layer.count; i++) {
        _clouds.add(_CloudSpec(
          top: layer.top + rand.nextDouble() * 0.18,
          scale: layer.scale * (0.85 + rand.nextDouble() * 0.3),
          speed: layer.speed * (0.8 + rand.nextDouble() * 0.4),
          startOffset: rand.nextDouble(),
          alpha: layer.alpha,
        ));
      }
    }

    _fireflies = List.generate(12, (i) {
      return _FireflySpec(
        bx: 0.08 + rand.nextDouble() * 0.84,
        by: 0.35 + rand.nextDouble() * 0.55,
        rx: 0.03 + rand.nextDouble() * 0.06,
        ry: 0.02 + rand.nextDouble() * 0.05,
        speedHz: 0.08 + rand.nextDouble() * 0.10,
        phase: rand.nextDouble() * 2 * pi,
        pulseHz: 0.4 + rand.nextDouble() * 0.6,
        pulsePhase: rand.nextDouble() * 2 * pi,
        size: 1.6 + rand.nextDouble() * 1.4,
        color: i % 3 == 0
            ? const Color(0xFFFFF3B0)
            : (i % 3 == 1
                ? const Color(0xFFD9F7C5)
                : const Color(0xFFC9F2DC)),
      );
    });
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
                    showAurora: widget.showAurora,
                    showFireflies: widget.showFireflies,
                    gradientColors: widget.gradientColors,
                    stars: _stars,
                    clouds: _clouds,
                    fireflies: _fireflies,
                    shootingStars: _shootingStars,
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

class _StarSpec {
  final double dx; // fraction of width
  final double dy; // fraction of height
  final double radius;
  final double phase;
  final double speedHz; // twinkle speed
  const _StarSpec({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.speedHz,
  });
}

class _CloudSpec {
  final double top; // fraction of height
  final double scale;
  final double speed; // width-fractions crossed per 60s loop
  final double startOffset;
  final double alpha;
  const _CloudSpec({
    required this.top,
    required this.scale,
    required this.speed,
    required this.startOffset,
    required this.alpha,
  });
}

class _FireflySpec {
  final double bx, by; // base position, fractions
  final double rx, ry; // wander extent, fractions
  final double speedHz; // wander speed
  final double phase;
  final double pulseHz; // glow pulse speed
  final double pulsePhase;
  final double size;
  final Color color;
  const _FireflySpec({
    required this.bx,
    required this.by,
    required this.rx,
    required this.ry,
    required this.speedHz,
    required this.phase,
    required this.pulseHz,
    required this.pulsePhase,
    required this.size,
    required this.color,
  });
}

class _ShootingStarSpec {
  final double t0, t1; // progress window within the 60s loop
  final double sx, sy, ex, ey; // start/end, fractions
  const _ShootingStarSpec({
    required this.t0,
    required this.t1,
    required this.sx,
    required this.sy,
    required this.ex,
    required this.ey,
  });
}

class _SkyPainter extends CustomPainter {
  final double progress; // 0..1 across the 60s loop
  final bool showClouds;
  final bool showStars;
  final bool showAurora;
  final bool showFireflies;
  final List<Color> gradientColors;
  final List<_StarSpec> stars;
  final List<_CloudSpec> clouds;
  final List<_FireflySpec> fireflies;
  final List<_ShootingStarSpec> shootingStars;

  _SkyPainter({
    required this.progress,
    required this.showClouds,
    required this.showStars,
    required this.showAurora,
    required this.showFireflies,
    required this.gradientColors,
    required this.stars,
    required this.clouds,
    required this.fireflies,
    required this.shootingStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final seconds = progress * 60;
    if (showAurora) _paintAurora(canvas, size);
    if (showStars) {
      _paintStars(canvas, size, seconds);
      _paintShootingStars(canvas, size);
    }
    if (showClouds) _paintClouds(canvas, size);
    if (showFireflies) _paintFireflies(canvas, size, seconds);
  }

  void _paintAurora(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final base = gradientColors[i % gradientColors.length];
      final phase = i * 2.1;
      final cx = size.width *
          (0.22 + 0.28 * i + 0.10 * sin(progress * 2 * pi + phase));
      final cy = size.height *
          (0.16 + 0.14 * i + 0.07 * cos(progress * 2 * pi * 0.7 + phase));
      final r = size.width * (0.5 + 0.08 * sin(progress * 2 * pi * 0.5 + i));
      final paint = Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.25)!.withValues(alpha: 0.14),
            base.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  void _paintStars(Canvas canvas, Size size, double seconds) {
    final starPaint = Paint()..color = Colors.white;
    for (final star in stars) {
      final twinkle =
          (sin(seconds * 2 * pi * star.speedHz + star.phase) + 1) / 2;
      starPaint.color =
          Colors.white.withValues(alpha: 0.25 + twinkle * 0.75);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        star.radius,
        starPaint,
      );
    }
  }

  void _paintShootingStars(Canvas canvas, Size size) {
    for (final spec in shootingStars) {
      final local = (progress - spec.t0) / (spec.t1 - spec.t0);
      if (local <= 0 || local >= 1) continue;
      final start = Offset(spec.sx * size.width, spec.sy * size.height);
      final end = Offset(spec.ex * size.width, spec.ey * size.height);
      final pos =
          Offset.lerp(start, end, Curves.easeOut.transform(local))!;
      final dir = (end - start) / (end - start).distance;
      final tailStart = pos - dir * 90;

      final tailPaint = Paint()
        ..strokeWidth = 2
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.9),
          ],
        ).createShader(Rect.fromPoints(tailStart, pos));
      canvas.drawLine(tailStart, pos, tailPaint);

      canvas.drawCircle(
        pos,
        7,
        Paint()..color = Colors.white.withValues(alpha: 0.25),
      );
      canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    for (final cloud in clouds) {
      final t = (progress * cloud.speed + cloud.startOffset) % 1.0;
      final x = -220 + t * (size.width + 440);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: cloud.alpha);
      _drawCloud(canvas, Offset(x, cloud.top * size.height), cloud.scale, paint);
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

  void _paintFireflies(Canvas canvas, Size size, double seconds) {
    for (final f in fireflies) {
      final x = size.width *
          (f.bx + f.rx * sin(seconds * 2 * pi * f.speedHz + f.phase));
      final y = size.height *
          (f.by +
              f.ry * cos(seconds * 2 * pi * f.speedHz * 0.8 + f.phase * 1.3));
      final pulse =
          (sin(seconds * 2 * pi * f.pulseHz + f.pulsePhase) + 1) / 2;
      final pos = Offset(x, y);

      canvas.drawCircle(
        pos,
        f.size * 3.2,
        Paint()..color = f.color.withValues(alpha: 0.07 + pulse * 0.10),
      );
      canvas.drawCircle(
        pos,
        f.size * 1.4,
        Paint()..color = f.color.withValues(alpha: 0.18 + pulse * 0.22),
      );
      canvas.drawCircle(
        pos,
        f.size * 0.55,
        Paint()..color = f.color.withValues(alpha: 0.55 + pulse * 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
