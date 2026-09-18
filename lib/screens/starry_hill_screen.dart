import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/section_header.dart';
import '../services/audio_manager.dart';

class StarryHillScreen extends StatefulWidget {
  const StarryHillScreen({super.key});

  @override
  State<StarryHillScreen> createState() => _StarryHillScreenState();
}

class _StarryHillScreenState extends State<StarryHillScreen>
    with TickerProviderStateMixin {
  final List<Offset> _heartPoints = _generateHeartPoints(16);
  int _revealed = 0;
  bool _showMessage = false;
  late final AnimationController _shootController;
  late final AnimationController _glow;
  late final AnimationController _sky; // slow drift for the Milky Way
  late final List<_MilkyWayDot> _milkyWayDots;

  @override
  void initState() {
    super.initState();
    _shootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _sky = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 90),
    )..repeat();

    // A diagonal band of faint dust across the upper sky.
    final rand = Random(21);
    const a = Offset(-0.05, 0.02);
    const b = Offset(1.05, 0.50);
    const perp = Offset(-0.5, 1.0);
    _milkyWayDots = List.generate(110, (_) {
      final t = rand.nextDouble();
      final base = Offset.lerp(a, b, t)!;
      final spread =
          (rand.nextDouble() + rand.nextDouble() + rand.nextDouble() - 1.5) /
              1.5 *
              0.10;
      final perpNorm = perp.distance;
      final pos = base +
          Offset(
            perp.dx / perpNorm * spread,
            perp.dy / perpNorm * spread,
          );
      return _MilkyWayDot(
        dx: pos.dx,
        dy: pos.dy,
        radius: 0.4 + rand.nextDouble() * 0.9,
        phase: rand.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _shootController.dispose();
    _glow.dispose();
    _sky.dispose();
    super.dispose();
  }

  static List<Offset> _generateHeartPoints(int count) {
    final points = <Offset>[];
    for (int i = 0; i < count; i++) {
      final t = (i / count) * 2 * pi;
      final x = 16 * pow(sin(t), 3);
      final y = -(13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));
      points.add(Offset(0.5 + x / 40, 0.5 + y / 40));
    }
    return points;
  }

  Future<void> _handleTap() async {
    if (_showMessage) return;
    if (_revealed < _heartPoints.length) {
      HapticFeedback.selectionClick();
      AudioManager.instance.play(Sfx.star);
      setState(() => _revealed++);
      if (_revealed == _heartPoints.length) {
        HapticFeedback.heavyImpact();
        AudioManager.instance.play(Sfx.complete);
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await _shootController.forward(from: 0);
        if (!mounted) return;
        setState(() => _showMessage = true);
        _glow.repeat(); // drives the heartbeat
        context.read<JourneyState>().completeStarryHill();
      }
    }
  }

  /// A double-thump heartbeat curve over each controller cycle (0..1).
  static double _heartbeat(double t) {
    double beat(double x) {
      if (x <= 0 || x >= 1) return 0;
      final s = sin(pi * x);
      return s * s * s * s;
    }

    final main = beat((t % 1.0) * 2);
    final echo = beat((((t - 0.35) % 1.0) + 1.0) % 1.0 * 2);
    return (main * 0.9 + echo * 0.55).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _handleTap,
        child: AnimatedSkyBackground(
          gradientColors: const [AppTheme.skyNightDeep, AppTheme.skyNight],
          showClouds: false,
          showStars: true,
          showAurora: true,
          child: SafeArea(
            child: Column(
              children: [
                SectionHeader(
                  title: 'Starry Hill',
                  subtitle: _showMessage ? '' : 'tap the sky, one star at a time',
                  color: AppTheme.textLight,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // The Milky Way, slowly drifting behind everything.
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _sky,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _MilkyWayPainter(
                                seconds: _sky.value * 90,
                                dots: _milkyWayDots,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _glow,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _ConstellationPainter(
                                points: _heartPoints,
                                revealed: _revealed,
                                pulse: _showMessage
                                    ? _heartbeat(_glow.value)
                                    : 0,
                              ),
                            );
                          },
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _shootController,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: CustomPaint(
                              painter: _ShootingStarPainter(
                                progress: _shootController.value,
                              ),
                            ),
                          );
                        },
                      ),
                      if (_showMessage)
                        Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 800),
                            opacity: 1,
                            child: Container(
                              margin: const EdgeInsets.all(28),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.nightSoft.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.lavender.withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                AppContent.constellationMessage,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MilkyWayDot {
  final double dx, dy; // fractions
  final double radius;
  final double phase;
  const _MilkyWayDot({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
  });
}

/// A soft diagonal dust band with faintly shimmering specks.
class _MilkyWayPainter extends CustomPainter {
  final double seconds;
  final List<_MilkyWayDot> dots;

  _MilkyWayPainter({required this.seconds, required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    // A few wide, ultra-soft glows along the band.
    const a = Offset(-0.05, 0.02);
    const b = Offset(1.05, 0.50);
    for (int i = 0; i < 4; i++) {
      final t = (i + 0.5) / 4;
      final center = Offset.lerp(a, b, t)!;
      final c = Offset(
        (center.dx + 0.01 * sin(seconds * 0.05 + i)) * size.width,
        center.dy * size.height,
      );
      final r = size.width * 0.20;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFBFD4FF).withValues(alpha: 0.06),
              const Color(0xFFBFD4FF).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    // Dust specks.
    final paint = Paint()..color = Colors.white;
    for (final d in dots) {
      final twinkle = (sin(seconds * 0.4 + d.phase) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.06 + twinkle * 0.16);
      canvas.drawCircle(
        Offset(d.dx * size.width, d.dy * size.height),
        d.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MilkyWayPainter oldDelegate) =>
      oldDelegate.seconds != seconds;
}

class _ConstellationPainter extends CustomPainter {
  final List<Offset> points;
  final int revealed;
  final double pulse; // heartbeat value 0..1 once complete
  _ConstellationPainter({
    required this.points,
    required this.revealed,
    this.pulse = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final complete = revealed >= points.length && points.length > 1;

    // The whole heart gently thumps with the pulse.
    canvas.save();
    if (complete && pulse > 0) {
      final c = Offset(size.width / 2, size.height / 2);
      final scale = 1.0 + pulse * 0.045;
      canvas.translate(c.dx, c.dy);
      canvas.scale(scale);
      canvas.translate(-c.dx, -c.dy);
    }

    final linePaint = Paint()
      ..color =
          Colors.white.withValues(alpha: 0.6 + pulse * 0.3)
      ..strokeWidth = 1.5 + pulse * 0.8;
    final starPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()..color = AppTheme.gold.withValues(alpha: 0.6);
    Offset? prev;

    for (int i = 0; i < revealed && i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (prev != null) {
        canvas.drawLine(prev, p, linePaint);
      }
      if (complete && pulse > 0) {
        final halo = Paint()
          ..color = AppTheme.gold.withValues(alpha: 0.2 + pulse * 0.45);
        canvas.drawCircle(p, 5 + pulse * 7, halo);
      }
      canvas.drawCircle(p, 5, glowPaint);
      canvas.drawCircle(p, 3, starPaint);
      prev = p;
    }

    if (complete && prev != null) {
      final first = Offset(
        points.first.dx * size.width,
        points.first.dy * size.height,
      );
      canvas.drawLine(prev, first, linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.revealed != revealed || oldDelegate.pulse != pulse;
}

class _ShootingStarPainter extends CustomPainter {
  final double progress;
  _ShootingStarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final start = Offset(size.width * 0.1, size.height * 0.1);
    final end = Offset(size.width * 0.9, size.height * 0.5);
    final pos = Offset.lerp(start, end, Curves.easeOut.transform(progress))!;

    // Soft outer glow around the head.
    canvas.drawCircle(
      pos,
      16,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.5),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: 16)),
    );

    // Tapered glowing tail.
    final tailPaint = Paint()
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromPoints(start, pos));
    canvas.drawLine(start, pos, tailPaint);

    canvas.drawCircle(
      pos,
      6,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
