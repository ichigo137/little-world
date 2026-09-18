import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../content.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../services/audio_manager.dart';
import 'hub_screen.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathe;
  late final AnimationController _open;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _open = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _breathe.dispose();
    _open.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_opening) return;
    setState(() => _opening = true);
    AudioManager.instance.startAmbient();
    await _open.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, anim, secAnim) => const HubScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightRose,
        showClouds: true,
        showAurora: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                key: const Key('gift_box'),
                onTap: _handleTap,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_breathe, _open]),
                  builder: (context, child) {
                    final breatheScale = 1.0 + _breathe.value * 0.04;
                    final openScale = 1.0 + _open.value * 0.6;
                    final openOpacity = (1.0 - _open.value * 1.2)
                        .clamp(0.0, 1.0);
                    return Opacity(
                      opacity: openOpacity,
                      child: Transform.scale(
                        scale: _opening ? openScale : breatheScale,
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 240,
                    height: 210,
                    child: AnimatedBuilder(
                      animation: _open,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _GiftBoxPainter(
                            open: _open.value,
                            breathe: _breathe.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                AppContent.herName,
                style: GoogleFonts.caveat(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppContent.heroTagline,
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(
                  fontSize: 14,
                  color: AppTheme.textSoft,
                ),
              ),
              const SizedBox(height: 28),
              // Shimmering hint: a brightness band sweeps across the text.
              ShaderMask(
                shaderCallback: (bounds) {
                  final t = (_breathe.value * 1.6 - 0.3).clamp(0.0, 1.0);
                  return LinearGradient(
                    begin: Alignment(-1.0 + 2 * t, 0),
                    end: Alignment(-0.4 + 2 * t, 0),
                    colors: const [
                      Colors.white,
                      AppTheme.gold,
                      Colors.white,
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  'tap to open your gift',
                  style: GoogleFonts.comfortaa(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
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

/// The gift box, drawn in three pieces: the glow + light rays behind
/// everything, the box body, and the lid that pops off with spin.
class _GiftBoxPainter extends CustomPainter {
  final double open; // 0..1 unwrap progress
  final double breathe; // 0..1 idle breathing, feeds the glow

  _GiftBoxPainter({required this.open, required this.breathe});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final boxW = w * 0.70;
    final boxLeft = (w - boxW) / 2;
    final bodyTop = h * 0.42;
    final bodyH = h * 0.40;
    final lidH = h * 0.14;

    _paintGlowAndRays(canvas, size, boxLeft, bodyTop, boxW);

    // ----- box body -----
    final bodyPaint = Paint()..color = AppTheme.blush;
    final bodyRect = Rect.fromLTWH(boxLeft, bodyTop, boxW, bodyH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)),
      bodyPaint,
    );
    // vertical ribbon stays with the body
    final ribbonPaint = Paint()..color = AppTheme.gold;
    canvas.drawRect(
      Rect.fromLTWH(
        w / 2 - boxW * 0.06,
        bodyTop,
        boxW * 0.12,
        bodyH,
      ),
      ribbonPaint,
    );

    // ----- lid (pops up, spins slightly, drifts sideways, fades) -----
    if (open < 1) {
      final lift = Curves.easeOutBack.transform(open) * h * 0.55;
      final drift = open * w * 0.22;
      final spin = open * 0.5; // radians
      final lidOpacity = (1.0 - open * 0.9).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(w / 2 + drift, bodyTop - lift);
      canvas.rotate(spin);
      final lidPaint = Paint()..color = AppTheme.peach.withValues(alpha: lidOpacity);
      final lidRibbon =
          Paint()..color = AppTheme.gold.withValues(alpha: lidOpacity);
      final lidRect = Rect.fromLTWH(-boxW / 2 - 6, -lidH, boxW + 12, lidH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(lidRect, const Radius.circular(10)),
        lidPaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(-boxW * 0.06, -lidH, boxW * 0.12, lidH),
        lidRibbon,
      );
      // bow rides on the lid
      final bowCenter = Offset(0, -lidH - 4);
      canvas.drawCircle(bowCenter.translate(-13, 0), 12, lidRibbon);
      canvas.drawCircle(bowCenter.translate(13, 0), 12, lidRibbon);
      canvas.drawCircle(
        bowCenter,
        7,
        Paint()..color = AppTheme.gold.withValues(alpha: lidOpacity * 0.95),
      );
      canvas.restore();
    }

    // ----- sparkles bursting out of the opening box -----
    if (open > 0.05) {
      final burstT = Curves.easeOut.transform(open);
      final sparklePaint = Paint();
      final rand = Random(3);
      for (int i = 0; i < 14; i++) {
        final angle = -pi / 2 + (rand.nextDouble() - 0.5) * 2.2;
        final dist = 20 + rand.nextDouble() * 90 * burstT;
        final pos = Offset(
          w / 2 + cos(angle) * dist,
          bodyTop + sin(angle) * dist,
        );
        final alpha =
            (1.0 - burstT) * (0.5 + rand.nextDouble() * 0.5);
        sparklePaint.color = (i % 3 == 0 ? AppTheme.gold : Colors.white)
            .withValues(alpha: alpha.clamp(0.0, 1.0));
        canvas.drawCircle(pos, 1.5 + rand.nextDouble() * 2.0, sparklePaint);
      }
    }
  }

  void _paintGlowAndRays(
    Canvas canvas,
    Size size,
    double boxLeft,
    double bodyTop,
    double boxW,
  ) {
    final center = Offset(size.width / 2, bodyTop);
    final glowStrength = open > 0.02 ? 0.55 : 0.18 + breathe * 0.14;

    // Soft radial glow from inside the box.
    canvas.drawCircle(
      center,
      size.width * (0.34 + open * 0.30),
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            AppTheme.gold.withValues(alpha: glowStrength),
            AppTheme.gold.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: size.width * (0.34 + open * 0.30),
          ),
        ),
    );

    // Light rays fan out as the box opens.
    if (open > 0.05) {
      final rayPaint = Paint()
        ..blendMode = BlendMode.plus
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 7; i++) {
        final angle =
            -pi / 2 + (i - 3) * 0.38 + sin(open * pi) * 0.05;
        final len = size.width * (0.28 + 0.1 * (i % 2)) * open;
        rayPaint.shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.45 * open),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromPoints(
          center,
          center + Offset(cos(angle), sin(angle)) * len,
        ));
        canvas.drawLine(
          center,
          center + Offset(cos(angle), sin(angle)) * len,
          rayPaint..strokeWidth = 3.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GiftBoxPainter oldDelegate) =>
      oldDelegate.open != open || oldDelegate.breathe != breathe;
}
