import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Soft light accents — the pastel soul of the app, now popping on dark.
  static const Color blush = Color(0xFFFFD6E8);
  static const Color lavender = Color(0xFFDCC9FF);
  static const Color mint = Color(0xFFC9F2DC);
  static const Color peach = Color(0xFFFFDFC0);
  static const Color gold = Color(0xFFE8B86D);

  // The little world at night: soft, deep, cozy.
  static const Color nightDeep = Color(0xFF1B1533); // deepest sky
  static const Color night = Color(0xFF282047); // main sky
  static const Color nightSoft = Color(0xFF3A315C); // elevated surface
  static const Color skyNight = Color(0xFF3B3255);
  static const Color skyNightDeep = Color(0xFF1F1B3A);

  // Night gradients (top → bottom), one vibe per corner of the world.
  static const List<Color> nightRose = [
    Color(0xFF241A44), // indigo
    Color(0xFF3A2A55), // dusky plum
    Color(0xFF523B5E), // mauve rose
  ];
  static const List<Color> nightMoss = [
    Color(0xFF16252B), // deep pine
    Color(0xFF22383C), // soft teal
    Color(0xFF2E4744), // mossy dusk
  ];

  // Ink: dark stays for light surfaces (QR code, polaroid cards),
  // light takes over for the night skies.
  static const Color textDark = Color(0xFF4A3B4F);
  static const Color textLight = Color(0xFFF4F0FF);
  static const Color textSoft = Color(0xFFBFB6DE);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nightDeep,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavender,
        brightness: Brightness.dark,
        surface: night,
      ),
      textTheme: GoogleFonts.comfortaaTextTheme(),
      fontFamily: GoogleFonts.comfortaa().fontFamily,
    );
  }
}
