import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/memory_reveal_card.dart';
import '../widgets/section_header.dart';
import '../services/audio_manager.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with TickerProviderStateMixin {
  late List<bool> _bloomed;
  late final AnimationController _world; // drives petals & butterflies
  late final List<_PetalSpec> _petals;
  late final List<_ButterflySpec> _butterflies;

  @override
  void initState() {
    super.initState();
    final journey = context.read<JourneyState>();
    _bloomed = journey.getOrInitGardenBloomed(AppContent.gardenMemories.length);
    _world = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final rand = Random(11);
    _petals = List.generate(14, (i) {
      return _PetalSpec(
        x: rand.nextDouble(),
        speed: 0.05 + rand.nextDouble() * 0.06,
        swayHz: 0.3 + rand.nextDouble() * 0.4,
        phase: rand.nextDouble() * 2 * pi,
        size: 4 + rand.nextDouble() * 4,
        color: _flowerColor(i),
      );
    });
    _butterflies = [
      const _ButterflySpec(
        yFrac: 0.30,
        crossSecs: 16,
        flapHz: 5.5,
        color: Color(0xFFF6C066),
        phase: 0,
      ),
      const _ButterflySpec(
        yFrac: 0.52,
        crossSecs: 22,
        flapHz: 6.5,
        color: Color(0xFFB08FE8),
        phase: 0.45,
      ),
    ];
  }

  @override
  void dispose() {
    _world.dispose();
    super.dispose();
  }

  void _checkComplete() {
    if (_bloomed.every((b) => b)) {
      context.read<JourneyState>().completeGarden();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightMoss,
        showClouds: true,
        showAurora: true,
        showFireflies: true,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SectionHeader(
                    title: 'The Garden of Us',
                    subtitle: 'tap a flower to let it bloom',
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(28),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: AppContent.gardenMemories.length,
                      itemBuilder: (context, index) {
                        return _Flower(
                          key: ValueKey('flower_$index'),
                          bloomed: _bloomed[index],
                          colorSeed: index,
                          onTap: () async {
                            if (!_bloomed[index]) {
                              HapticFeedback.mediumImpact();
                              context.read<JourneyState>().bloomFlower(index);
                              setState(() {});
                              AudioManager.instance.play(Sfx.bloom);
                            }
                            await showMemoryReveal(
                              context,
                              AppContent.gardenMemories[index],
                              accent: _flowerColor(index),
                            );
                            _checkComplete();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Falling petals drift over everything, under the dialogs.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _world,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _GardenLifePainter(
                          seconds: _world.value * 30,
                          petals: _petals,
                          butterflies: _butterflies,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _flowerColor(int i) {
  const colors = [
    Color(0xFFEF9FBF),
    Color(0xFFF6C066),
    Color(0xFFB08FE8),
    Color(0xFF8FBF87),
    Color(0xFF7FC7D9),
    Color(0xFFE8846C),
  ];
  return colors[i % colors.length];
}

/// Falling petals + gently flapping butterflies, drawn over the garden.
class _GardenLifePainter extends CustomPainter {
  final double seconds; // elapsed seconds across the 30s loop
  final List<_PetalSpec> petals;
  final List<_ButterflySpec> butterflies;

  _GardenLifePainter({
    required this.seconds,
    required this.petals,
    required this.butterflies,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final fallSecs = 9 + p.speed * 40; // ~11-15s to cross the screen
      final t = (seconds / fallSecs + p.phase / (2 * pi)) % 1.0;
      final x = size.width *
          (p.x + 0.04 * sin(seconds * 2 * pi * p.swayHz + p.phase));
      final y = -20 + t * (size.height + 40);
      final angle = sin(t * 2 * pi * p.swayHz * 2 + p.phase) * 0.8;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, -p.size)
        ..quadraticBezierTo(p.size, 0, 0, p.size)
        ..quadraticBezierTo(-p.size, 0, 0, -p.size)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = p.color.withValues(alpha: 0.55),
      );
      canvas.restore();
    }

    for (final b in butterflies) {
      // Bounce back and forth across the screen.
      final sweep = (seconds / b.crossSecs + b.phase) % 2.0;
      final goingRight = sweep < 1.0;
      final t = goingRight ? sweep : 2.0 - sweep;
      final x = 40 + t * (size.width - 80);
      final y = size.height * b.yFrac +
          16 * sin(seconds * 2 * pi * 0.15 + b.phase * 6);
      final flap = (sin(seconds * 2 * pi * b.flapHz) + 1) / 2;
      final dir = goingRight ? 1.0 : -1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(dir, 1);
      final wing = Paint()..color = b.color.withValues(alpha: 0.85);
      // Two wings, squashing with the flap.
      for (final s in [-1.0, 1.0]) {
        canvas.save();
        canvas.scale(0.35 + flap * 0.65, 1.0);
        final wingPath = Path()
          ..addOval(
            Rect.fromCenter(
              center: Offset(s * 8, -4),
              width: 18,
              height: 12,
            ),
          );
        canvas.drawPath(wingPath, wing);
        canvas.restore();
      }
      canvas.drawCircle(
        const Offset(0, -2),
        2.2,
        Paint()..color = const Color(0xFF4A3B4F),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GardenLifePainter oldDelegate) =>
      oldDelegate.seconds != seconds;
}

class _PetalSpec {
  final double x;
  final double speed; // feeds fall duration: 9 + speed*40 seconds
  final double swayHz;
  final double phase;
  final double size;
  final Color color;
  const _PetalSpec({
    required this.x,
    required this.speed,
    required this.swayHz,
    required this.phase,
    required this.size,
    required this.color,
  });
}

class _ButterflySpec {
  final double yFrac;
  final double crossSecs; // seconds to cross the screen once
  final double flapHz;
  final double phase;
  final Color color;
  const _ButterflySpec({
    required this.yFrac,
    required this.crossSecs,
    required this.flapHz,
    required this.phase,
    required this.color,
  });
}

/// A hand-painted flower: a stem that grows out of the ground, leaves
/// that unfold, and petals that open one by one when bloomed.
class _Flower extends StatelessWidget {
  final bool bloomed;
  final int colorSeed;
  final VoidCallback onTap;

  const _Flower({
    super.key,
    required this.bloomed,
    required this.colorSeed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: bloomed ? 1 : 0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            size: const Size(72, 96),
            painter: _FlowerPainter(
              color: _flowerColor(colorSeed),
              growth: value,
            ),
          );
        },
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  final Color color;
  final double growth; // 0 = bud/seed, 1 = fully bloomed

  _FlowerPainter({required this.color, required this.growth});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height - 4;
    final bloomY = size.height * 0.30;

    final stemPaint = Paint()
      ..color = const Color(0xFF7FA97C)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Stem grows with progress, with a gentle S-curve.
    final growH = (bloomY - baseY) * growth;
    if (growH > 2) {
      final path = Path()
        ..moveTo(cx, baseY)
        ..cubicTo(
          cx + 6, baseY - growH * 0.33,
          cx - 6, baseY - growH * 0.66,
          cx, baseY - growH,
        );
      canvas.drawPath(path, stemPaint);

      // Leaves unfold once the stem is mostly grown.
      final leafT = ((growth - 0.45) / 0.55).clamp(0.0, 1.0);
      if (leafT > 0) {
        _drawLeaf(
            canvas, Offset(cx - 2, baseY - growH * 0.45), -2.2, 11 * leafT);
        _drawLeaf(
            canvas, Offset(cx + 2, baseY - growH * 0.62), 2.2 - pi, 11 * leafT);
      }
    }

    if (growth < 0.15) {
      // A tiny sprout before blooming starts.
      canvas.drawCircle(
        Offset(cx, baseY - 4),
        3,
        Paint()..color = const Color(0xFF9DBF8A),
      );
      return;
    }

    // Petals unfold one by one: each petal scales in on its own slice
    // of the growth timeline.
    const petals = 6;
    final petalLen = size.height * 0.16;
    final bloom = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < petals; i++) {
      final start = 0.55 + (i / petals) * 0.35;
      final t = ((growth - start) / 0.12).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final angle = (i / petals) * 2 * pi - pi / 2;
      final len = petalLen * Curves.elasticOut.transform(t);
      canvas.save();
      canvas.translate(cx, baseY - growH);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(petalLen * 0.45, -petalLen * 0.35, len, 0)
        ..quadraticBezierTo(petalLen * 0.45, petalLen * 0.35, 0, 0)
        ..close();
      bloom.color = color.withValues(alpha: 0.9);
      canvas.drawPath(path, bloom);
      canvas.restore();
    }

    // Golden center pops in at the very end.
    final centerT = ((growth - 0.88) / 0.12).clamp(0.0, 1.0);
    if (centerT > 0) {
      canvas.drawCircle(
        Offset(cx, baseY - growH),
        5.5 * Curves.easeOutBack.transform(centerT),
        Paint()..color = const Color(0xFFE8B86D),
      );
    }
  }

  void _drawLeaf(Canvas canvas, Offset origin, double angle, double len) {
    if (len <= 1) return;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.45, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.45, 0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF7FA97C));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter oldDelegate) =>
      oldDelegate.growth != growth;
}
