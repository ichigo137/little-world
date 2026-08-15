import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../content.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/section_header.dart';

/// The last little surprise: a scannable QR code hiding the live
/// secret site. Tapping the code or the button opens it in her
/// browser. Same soft pastel world as everywhere else.
class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hint;
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _hint = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hint.dispose();
    super.dispose();
  }

  Future<void> _openLink() async {
    if (_opening) return;
    setState(() => _opening = true);
    final uri = Uri.parse(AppContent.secretLinkUrl);
    var launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }
    if (!mounted) return;
    setState(() => _opening = false);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'couldn\u2019t open it — the link is hiding in the code',
            style: GoogleFonts.comfortaa(),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.nightSoft,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightRose,
        showClouds: true,
        child: SafeArea(
          child: Column(
            children: [
              const SectionHeader(
                title: 'a secret for you',
                subtitle: 'one last little thing, tucked inside a code',
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: 0.8 + value * 0.2,
                                child: child,
                              ),
                            );
                          },
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: GestureDetector(
                              onTap: _openLink,
                              child: Transform.rotate(
                                angle: -0.015,
                                child: Container(
                                  width: 300,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 24, 20, 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      QrImageView(
                                        data: AppContent.secretLinkUrl,
                                        version: QrVersions.auto,
                                        errorCorrectionLevel:
                                            QrErrorCorrectLevel.M,
                                        size: 210,
                                        backgroundColor: Colors.white,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: AppTheme.textDark,
                                        ),
                                        dataModuleStyle:
                                            const QrDataModuleStyle(
                                          dataModuleShape:
                                              QrDataModuleShape.square,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lavender
                                              .withValues(alpha: 0.35),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.link_rounded,
                                              size: 15,
                                              color: AppTheme.textDark,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                AppContent.secretLinkUrl
                                                    .replaceFirst(
                                                        'https://', ''),
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.comfortaa(
                                                  fontSize: 12,
                                                  color: AppTheme.textDark,
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _hint,
                          builder: (context, child) => Opacity(
                            opacity: 0.55 + _hint.value * 0.45,
                            child: child,
                          ),
                          child: Text(
                            'scan it, or tap the code to open it',
                            style: GoogleFonts.comfortaa(
                              fontSize: 12,
                              color: AppTheme.textSoft,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _openLink,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.lavender,
                            foregroundColor: AppTheme.nightDeep,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(
                            'open the surprise',
                            style: GoogleFonts.comfortaa(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
