import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../content.dart';
import '../theme/app_theme.dart';

/// Shows a memory in a polaroid-style card that drops in with a
/// gentle elastic bounce. Falls back to a soft placeholder if no
/// photo has been added yet, so the app looks complete either way.
Future<void> showMemoryReveal(
  BuildContext context,
  MemoryItem memory, {
  required Color accent,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'memory',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 550),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final bounce = CurvedAnimation(parent: anim, curve: Curves.elasticOut);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * -50),
          child: Transform.scale(
            scale: 0.7 + bounce.value * 0.3,
            child: _MemoryCard(memory: memory, accent: accent),
          ),
        ),
      );
    },
  );
}

class _MemoryCard extends StatelessWidget {
  final MemoryItem memory;
  final Color accent;
  const _MemoryCard({required this.memory, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.02,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (memory.photoAsset != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      memory.photoAsset!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          _placeholderPhoto(accent),
                    ),
                  )
                else
                  _placeholderPhoto(accent),
                const SizedBox(height: 14),
                Text(
                  memory.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 15,
                    color: AppTheme.textDark,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(Icons.favorite, color: accent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderPhoto(Color accent) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.favorite_rounded, color: accent, size: 42),
    );
  }
}
