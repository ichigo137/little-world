import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color blush = Color(0xFFFFD6E8);
  static const Color cream = Color(0xFFFFF7F0);
  static const Color lavender = Color(0xFFE8D9FF);
  static const Color mint = Color(0xFFD6F5E8);
  static const Color peach = Color(0xFFFFE3C7);
  static const Color skyNight = Color(0xFF3B3255);
  static const Color skyNightDeep = Color(0xFF1F1B3A);
  static const Color textDark = Color(0xFF4A3B4F);
  static const Color gold = Color(0xFFE8B86D);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: blush,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.comfortaaTextTheme(),
      fontFamily: GoogleFonts.comfortaa().fontFamily,
    );
  }
}
