import 'package:flutter/material.dart';

/// Lightweight Material 3 themes shared by every screen.
///
/// The app leans on color, spacing and shape instead of heavy effects: no custom
/// fonts, no image backgrounds and no expensive shaders in normal scrolling UI.
class AppTheme {
  AppTheme._();

  static const Color pokemonRed = Color(0xFFE3350D);
  static const Color pokemonBlue = Color(0xFF30A7D7);
  static const Color amoledBlack = Color(0xFF000000);
  static const Color sleekDarkGray = Color(0xFF121212);

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: pokemonRed,
      brightness: brightness,
      primary: pokemonRed,
      secondary: pokemonBlue,
      surface: isDark ? amoledBlack : const Color(0xFFF8FAFC),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? amoledBlack : const Color(0xFFF8FAFC),
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? amoledBlack : Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? sleekDarkGray : Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: isDark ? const Color(0xFF242424) : const Color(0xFFE5E7EB)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF171717) : const Color(0xFFF1F5F9),
        selectedColor: pokemonRed,
        labelStyle: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        side: BorderSide(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFFFFFFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: pokemonRed, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pokemonRed,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
