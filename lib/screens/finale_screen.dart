import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../services/audio_manager.dart';
import 'gift_screen.dart';
import 'playlist_screen.dart';
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

  StreamSubscription<NoiseReading>? _noiseSub;
  bool _micOn = false;
  double _micLevel = 0;
  double _baseline = 60;
  double _baselineSum = 0;
  int _baselineSamples = 0;
  int _blowStreak = 0;

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
    _stopMic();
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
      _stopMic();
      setState(() => _blownOut = true);
      HapticFeedback.heavyImpact();
      AudioManager.instance.play(Sfx.candle);
      _confetti.play();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showFinale = true);
      });
    }
  }

  Future<void> _toggleMic() async {
    if (_micOn) {
      _stopMic();
      return;
    }
    if (_blownOut) return;
    var granted = await Permission.microphone.isGranted;
    if (!granted) {
      granted = await Permission.microphone.request().isGranted;
    }
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'mic isn\u2019t allowed here \u2014 hold the circle to blow instead',
            style: GoogleFonts.comfortaa(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.nightSoft,
        ),
      );
      return;
    }
    _baselineSum = 0;
    _baselineSamples = 0;
    _blowStreak = 0;
    setState(() {
      _micOn = true;
      _micLevel = 0;
    });
    _noiseSub = NoiseMeter().noise.listen(
      _onNoise,
      onError: (_) => _stopMic(),
      cancelOnError: true,
    );
  }

  void _onNoise(NoiseReading reading) {
    final level = reading.meanDecibel;
    if (_baselineSamples < 8) {
      _baselineSum += level;
      _baselineSamples++;
      if (_baselineSamples == 8) {
        _baseline = _baselineSum / _baselineSamples;
      }
      return;
    }
    final delta = level - _baseline;
    if (delta > 14) {
      _blowStreak++;
    } else {
      _blowStreak = 0;
    }
    if (!mounted) return;
    setState(() {
      _micLevel = (delta.clamp(0, 30) / 30).clamp(0.0, 1.0).toDouble();
    });
    if (_blowStreak >= 6) {
      _startBlow();
    }
  }

  void _stopMic() {
    final sub = _noiseSub;
    _noiseSub = null;
    sub?.cancel();
    if (mounted && _micOn) {
      setState(() {
        _micOn = false;
        _micLevel = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightRose,
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
            color: AppTheme.textLight,
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
                  color: AppTheme.nightSoft,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45), blurRadius: 16),
                  ],
                  border: Border.all(
                    color: AppTheme.lavender.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
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
                        backgroundColor: AppTheme.gold.withValues(alpha: 0.15),
                      ),
                    ),
                    const Icon(Icons.air, color: AppTheme.textLight, size: 30),
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
              fontSize: 12, color: AppTheme.textSoft), 
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _toggleMic,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.nightSoft.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.lavender.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _flicker,
                  builder: (context, child) {
                    final pulse = 0.6 + _flicker.value * 0.4;
                    final micOn = _micOn;
                    return Opacity(
                      opacity: micOn ? pulse : 0.8,
                      child: child,
                    );
                  },
                  child: Icon(
                    _micOn
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    size: 16,
                    color: _micOn ? AppTheme.gold : AppTheme.textSoft,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _micOn ? 'blow into the phone\u2026' : 'or use my voice',
                  style: GoogleFonts.comfortaa(
                    fontSize: 12,
                    color: _micOn ? AppTheme.gold : AppTheme.textSoft,
                  ),
                ),
                if (_micOn) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: LinearProgressIndicator(
                      value: _micLevel,
                      minHeight: 4,
                      color: AppTheme.mint,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
                AppContent.finaleMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.comfortaa(
                    fontSize: 14, height: 1.6, color: AppTheme.textLight),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => _openSecret(context),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.blush.withValues(alpha: 0.16),
                foregroundColor: AppTheme.textLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: const StadiumBorder(),
                side: const BorderSide(
                  color: AppTheme.blush,
                  width: 1.5,
                ),
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
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _openPlaylist(context),
              icon: const Icon(Icons.music_note_rounded, color: AppTheme.mint),
              label: Text(
                'the soundtrack of us',
                style: GoogleFonts.comfortaa(color: AppTheme.textSoft),
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
              icon: const Icon(Icons.replay_rounded, color: AppTheme.textSoft),
              label: Text(
                'replay the journey',
                style: GoogleFonts.comfortaa(color: AppTheme.textSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlaylist(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim, secAnim) => const PlaylistScreen(),
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
              width: 1.5, height: 30, color: widget.color.withValues(alpha: 0.5)),
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
      ..color = const Color(0xFFCFC4E8)
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
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFF6C066), Color(0xFFEF9FBF)],
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
