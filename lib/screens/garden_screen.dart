import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/memory_reveal_card.dart';
import '../widgets/section_header.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  late final List<bool> _bloomed;

  @override
  void initState() {
    super.initState();
    _bloomed = List.filled(AppContent.gardenMemories.length, false);
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
        child: SafeArea(
          child: Column(
            children: [
              const SectionHeader(
                title: 'The Garden of Us',
                subtitle: 'tap a flower to let it bloom',
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(28),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: AppContent.gardenMemories.length,
                  itemBuilder: (context, index) {
                    return _Flower(
                      bloomed: _bloomed[index],
                      colorSeed: index,
                      onTap: () async {
                        if (!_bloomed[index]) {
                          setState(() => _bloomed[index] = true);
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

class _Flower extends StatelessWidget {
  final bool bloomed;
  final int colorSeed;
  final VoidCallback onTap;

  const _Flower({
    required this.bloomed,
    required this.colorSeed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _flowerColor(colorSeed);
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: bloomed ? 1 : 0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.6 + value * 0.4,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              bloomed ? Icons.local_florist_rounded : Icons.eco_rounded,
              size: 44,
              color: bloomed ? color : Colors.green.shade300,
            ),
            if (bloomed) Icon(Icons.circle, size: 6, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
