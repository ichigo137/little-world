import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../content.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import 'hub_screen.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 900),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleTap,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_breathe, _open]),
                  builder: (context, child) {
                    final breatheScale = 1.0 + _breathe.value * 0.04;
                    final openScale = 1.0 + _open.value * 0.6;
                    final openOpacity = (1.0 - _open.value).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: openOpacity,
                      child: Transform.scale(
                        scale: _opening ? openScale : breatheScale,
                        child: child,
                      ),
                    );
                  },
                  child: CustomPaint(
                    size: const Size(180, 160),
                    painter: _GiftBoxPainter(),
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
              AnimatedBuilder(
                animation: _breathe,
                builder: (context, child) => Opacity(
                  opacity: 0.5 + _breathe.value * 0.5,
                  child: child,
                ),
                child: Text(
                  'tap to open your gift',
                  style: GoogleFonts.comfortaa(
                    fontSize: 13,
                    color: AppTheme.textSoft.withValues(alpha: 0.9),
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

class _GiftBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()..color = AppTheme.blush;
    final lidPaint = Paint()..color = AppTheme.peach;
    final ribbonPaint = Paint()..color = AppTheme.gold;

    final lidRect = Rect.fromLTWH(0, size.height * 0.28, size.width, size.height * 0.18);
    final bodyRect = Rect.fromLTWH(
      size.width * 0.06,
      size.height * 0.46,
      size.width * 0.88,
      size.height * 0.5,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(10)), boxPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(lidRect, const Radius.circular(10)), lidPaint);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.44, size.height * 0.28, size.width * 0.12, size.height * 0.68),
      ribbonPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.34, size.width, size.width * 0.1),
      ribbonPaint,
    );

    final center = Offset(size.width * 0.5, size.height * 0.22);
    canvas.drawCircle(center.translate(-14, 0), 14, ribbonPaint);
    canvas.drawCircle(center.translate(14, 0), 14, ribbonPaint);
    canvas.drawCircle(center, 8, Paint()..color = AppTheme.gold.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
