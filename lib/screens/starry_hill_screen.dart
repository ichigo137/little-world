import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/section_header.dart';

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

  @override
  void initState() {
    super.initState();
    _shootController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _shootController.dispose();
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
      setState(() => _revealed++);
      if (_revealed == _heartPoints.length) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await _shootController.forward(from: 0);
        if (!mounted) return;
        setState(() => _showMessage = true);
        context.read<JourneyState>().completeStarryHill();
      }
    }
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
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _ConstellationPainter(
                            points: _heartPoints,
                            revealed: _revealed,
                          ),
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

class _ConstellationPainter extends CustomPainter {
  final List<Offset> points;
  final int revealed;
  _ConstellationPainter({required this.points, required this.revealed});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5;
    final starPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()..color = AppTheme.gold.withOpacity(0.6);

    Offset? prev;
    for (int i = 0; i < revealed && i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if (prev != null) {
        canvas.drawLine(prev, p, linePaint);
      }
      canvas.drawCircle(p, 5, glowPaint);
      canvas.drawCircle(p, 3, starPaint);
      prev = p;
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.revealed != revealed;
}

class _ShootingStarPainter extends CustomPainter {
  final double progress;
  _ShootingStarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final start = Offset(size.width * 0.1, size.height * 0.1);
    final end = Offset(size.width * 0.9, size.height * 0.5);
    final pos = Offset.lerp(start, end, progress)!;
    final tailPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0), Colors.white],
      ).createShader(Rect.fromPoints(start, pos))
      ..strokeWidth = 2;
    canvas.drawLine(start, pos, tailPaint);
    canvas.drawCircle(pos, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ShootingStarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
