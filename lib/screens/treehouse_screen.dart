import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/memory_reveal_card.dart';
import '../widgets/section_header.dart';

class TreehouseScreen extends StatefulWidget {
  const TreehouseScreen({super.key});

  @override
  State<TreehouseScreen> createState() => _TreehouseScreenState();
}

class _TreehouseScreenState extends State<TreehouseScreen> {
  late final List<bool> _lit;

  @override
  void initState() {
    super.initState();
    _lit = List.filled(AppContent.treehouseMemories.length, false);
  }

  void _checkComplete() {
    if (_lit.every((b) => b)) {
      context.read<JourneyState>().completeTreehouse();
    }
  }

  List<Offset> _windowPositions(int count) {
    const base = [
      Offset(0.3, 0.45),
      Offset(0.62, 0.4),
      Offset(0.45, 0.62),
      Offset(0.25, 0.7),
      Offset(0.68, 0.65),
    ];
    return base.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightMoss,
        showClouds: true,
        child: SafeArea(
          child: Column(
            children: [
              const SectionHeader(
                title: 'The Treehouse',
                subtitle: 'light up every window',
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: CustomPaint(
                      painter: _TreehousePainter(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final positions =
                              _windowPositions(AppContent.treehouseMemories.length);
                          return Stack(
                            children: List.generate(
                              AppContent.treehouseMemories.length,
                              (i) {
                                final pos = positions[i];
                                return Positioned(
                                  left: pos.dx * constraints.maxWidth - 22,
                                  top: pos.dy * constraints.maxHeight - 22,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (!_lit[i]) setState(() => _lit[i] = true);
                                      await showMemoryReveal(
                                        context,
                                        AppContent.treehouseMemories[i],
                                        accent: const Color(0xFF8FBF87),
                                      );
                                      _checkComplete();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _lit[i]
                                            ? const Color(0xFFFFE9A8)
                                            : const Color(0xFF3F3126),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF2E241C),
                                          width: 3,
                                        ),
                                        boxShadow: _lit[i]
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFFFE9A8)
                                                      .withValues(alpha: 0.8),
                                                  blurRadius: 16,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
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

class _TreehousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()..color = const Color(0xFF6E5544);
    final leafPaint = Paint()..color = const Color(0xFF7FA97C);
    final houseTint = Paint()..color = const Color(0xFF5E4638);

    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.42, size.height * 0.55, size.width * 0.16, size.height * 0.45),
      trunkPaint,
    );
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.28), size.width * 0.42, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.4), size.width * 0.26, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4), size.width * 0.26, leafPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.35, size.width * 0.7, size.height * 0.45),
        const Radius.circular(16),
      ),
      houseTint,
    );

    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.35)
      ..lineTo(size.width * 0.5, size.height * 0.15)
      ..lineTo(size.width * 0.9, size.height * 0.35)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF46342A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
