import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../content.dart';
import '../state/journey_state.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/hub_node.dart';
import 'garden_screen.dart';
import 'treehouse_screen.dart';
import 'starry_hill_screen.dart';
import 'finale_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journey = context.watch<JourneyState>();
    return Scaffold(
      body: AnimatedSkyBackground(
        gradientColors: AppTheme.nightMoss,
        showClouds: true,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to your little world',
                style: GoogleFonts.caveat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                'tap around and explore, ${AppContent.herName}',
                style: GoogleFonts.comfortaa(
                  fontSize: 13,
                  color: AppTheme.textSoft,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: [
                  HubNode(
                    icon: Icons.local_florist_rounded,
                    label: 'Garden',
                    color: const Color(0xFFEF9FBF),
                    done: journey.gardenVisited,
                    onTap: () => _go(context, const GardenScreen()),
                  ),
                  HubNode(
                    icon: Icons.forest_rounded,
                    label: 'Treehouse',
                    color: const Color(0xFF8FBF87),
                    bobOffset: 6,
                    done: journey.treehouseVisited,
                    onTap: () => _go(context, const TreehouseScreen()),
                  ),
                  HubNode(
                    icon: Icons.nightlight_round,
                    label: 'Starry Hill',
                    color: const Color(0xFF8E86C9),
                    bobOffset: 12,
                    done: journey.starryHillVisited,
                    onTap: () => _go(context, const StarryHillScreen()),
                  ),
                  HubNode(
                    icon: Icons.cake_rounded,
                    label: 'The Surprise',
                    color: const Color(0xFFE8B86D),
                    locked: !journey.allChaptersDone,
                    onTap: () => _go(context, const FinaleScreen()),
                  ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, anim, secAnim) => screen,
        transitionsBuilder: (context, anim, secAnim, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
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
}
