import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import 'gift_screen.dart';
import 'qr_screen.dart';

class FinaleScreen extends StatefulWidget {
  const FinaleScreen({super.key});

  @override
  State<FinaleScreen> createState() => _FinaleScreenState();
}

class _FinaleScreenState extends State<FinaleScreen>
    with TickerProviderStateMixin {
  late final AnimationController _flicker;
  late final AnimationController _blowProgress;
  late final ConfettiController _confetti;
  bool _blownOut = false;
  bool _showFinale = false;

  @override
  void initState() {
    super.initState();
    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _blowProgress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addStatusListener(_onBlowStatus);
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _flicker.dispose();
    _blowProgress.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _startBlow() {
    if (_blownOut) return;
    _blowProgress.forward();
  }

  void _cancelBlow() {
    if (_blownOut) return;
    if (_blowProgress.value < 1.0) {
      _blowProgress.reverse();
    }
  }

  void _onBlowStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_blownOut) {
      setState(() => _blownOut = true);
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showFinale = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: const [
          AppTheme.peach,
          AppTheme.blush,
          AppTheme.lavender
        ],
        showClouds: true,
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: _showFinale
                    ? _buildFinaleContent(context)
                    : _buildCandleContent(),
              ),
            ),
            if (_blownOut) ..._buildBalloons(context),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                numberOfParticles: 24,
                gravity: 0.25,
                colors: const [
                  AppTheme.blush,
                  AppTheme.gold,
                  AppTheme.lavender,
                  AppTheme.mint
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandleContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Make a wish...',
          style: GoogleFonts.caveat(
            fontSize: 30,
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: Listenable.merge([_flicker, _blowProgress]),
          builder: (context, child) {
            final flameHeight = _blownOut
                ? 0.0
                : (1 - _blowProgress.value) * (36 + _flicker.value * 6);
            return SizedBox(
              width: 60,
              height: 140,
              child: CustomPaint(
                  painter: _CandlePainter(flameHeight: flameHeight)),
            );
          },
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onLongPressStart: (_) => _startBlow(),
          onLongPressEnd: (_) => _cancelBlow(),
          onLongPressCancel: () => _cancelBlow(),
          child: AnimatedBuilder(
            animation: _blowProgress,
            builder: (context, child) {
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 12),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: _blowProgress.value,
                        strokeWidth: 5,
                        color: AppTheme.gold,
                        backgroundColor: AppTheme.gold.withOpacity(0.15),
                      ),
                    ),
                    const Icon(Icons.air, color: AppTheme.textDark, size: 30),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'hold to blow',
          style: GoogleFonts.comfortaa(
              fontSize: 12, color: AppTheme.textDark.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildFinaleContent(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 900),
      opacity: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.gold, Color(0xFFEF9FBF)],
              ).createShader(bounds),
              child: Text(
                AppContent.finaleTitle,
                style: GoogleFonts.caveat(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              AppContent.herName,
              style: GoogleFonts.caveat(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                AppContent.finaleMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(
                    fontSize: 14, height: 1.6, color: AppTheme.textDark),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _openSecret(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.blush.withValues(alpha: 0.5),
                foregroundColor: AppTheme.textDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: const StadiumBorder(),
                side: const BorderSide(color: AppTheme.blush, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'one more little thing',
                    style: GoogleFonts.caveat(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                context.read<JourneyState>().reset();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GiftScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.replay_rounded, color: AppTheme.textDark),
              label: Text(
                'replay the journey',
                style: GoogleFonts.comfortaa(color: AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSecret(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim, secAnim) => const QrScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildBalloons(BuildContext context) {
    final colors = [
      AppTheme.blush,
      AppTheme.gold,
      AppTheme.lavender,
      AppTheme.mint,
      const Color(0xFFE8846C),
    ];
    return List.generate(6, (i) {
      return _Balloon(
          color: colors[i % colors.length],
          delay: i * 300,
          xFraction: 0.1 + i * 0.15);
    });
  }
}

class _Balloon extends StatefulWidget {
  final Color color;
  final int delay;
  final double xFraction;
  const _Balloon(
      {required this.color, required this.delay, required this.xFraction});

  @override
  State<_Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<_Balloon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final y = size.height * (1.1 - t * 1.3);
        final sway = sin(t * 6) * 14;
        final opacity = (1 - t) < 0.15 ? 0.0 : 1.0;
        return Positioned(
          left: size.width * widget.xFraction + sway,
          top: y,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: Column(
        children: [
          Container(
            width: 34,
            height: 42,
            decoration: BoxDecoration(
                color: widget.color, borderRadius: BorderRadius.circular(20)),
          ),
          Container(
              width: 1.5, height: 30, color: widget.color.withOpacity(0.5)),
        ],
      ),
    );
  }
}

class _CandlePainter extends CustomPainter {
  final double flameHeight;
  _CandlePainter({required this.flameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final waxPaint = Paint()..color = AppTheme.blush;
    final wickPaint = Paint()
      ..color = const Color(0xFF4A3B4F)
      ..strokeWidth = 2;
    final baseY = size.height - 20;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.3, size.width * 0.4,
            baseY - size.height * 0.3),
        const Radius.circular(6),
      ),
      waxPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.3 - 10),
      wickPaint,
    );

    if (flameHeight > 1) {
      final flameBaseY = size.height * 0.3 - 10;
      final flameTop = Offset(size.width * 0.5, flameBaseY - flameHeight);
      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: const [Color(0xFFF6C066), Color(0xFFEF9FBF)],
        ).createShader(
            Rect.fromLTWH(size.width * 0.5 - 10, flameTop.dy, 20, flameHeight));
      final path = Path()
        ..moveTo(size.width * 0.5, flameBaseY)
        ..quadraticBezierTo(size.width * 0.5 - 10,
            flameBaseY - flameHeight * 0.5, flameTop.dx, flameTop.dy)
        ..quadraticBezierTo(size.width * 0.5 + 10,
            flameBaseY - flameHeight * 0.5, size.width * 0.5, flameBaseY)
        ..close();
      canvas.drawPath(path, flamePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.flameHeight != flameHeight;
}
