import 'package:flutter/material.dart';

/// Cinematic theme configurations for LibreDex.
/// Focuses on Material 3 with an AMOLED-friendly true black dark mode and clean light mode.
class AppTheme {
  AppTheme._();

  // Premium Palette Colors
  static const Color pokemonRed = Color(0xFFE3350D); // PokéAPI Red
  static const Color pokemonBlue = Color(0xFF30A7D7); // Accent Blue
  static const Color amoledBlack = Color(0xFF000000); // True Black for Battery Saving
  static const Color sleekDarkGray = Color(0xFF121212); // Secondary Dark Surface

  /// Elegant Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pokemonRed,
        brightness: Brightness.light,
        primary: pokemonRed,
        secondary: pokemonBlue,
        surface: const Color(0xFFF8F9FA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: pokemonRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Premium AMOLED Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: pokemonRed,
        secondary: pokemonBlue,
        surface: amoledBlack, // True AMOLED black background
        surfaceContainer: sleekDarkGray, // Sleek dark surface cards
        onSurface: Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: amoledBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: amoledBlack,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: sleekDarkGray,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222222), width: 1), // Subtle borders instead of shadows
        ),
      ),
    );
  }
}
