import 'package:flutter/material.dart';

class AidaColors {
  static const primary = Color(0xFF196F77);
  static const accent = Color(0xFF3BB7B4);
  static const gold = Color(0xFFF2B84D);
  static const surface = Color(0xFFF7F7F7);
  static const surfaceDark = Color(0xFF1A1A2E);
  static const card = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF252540);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textPrimaryDark = Color(0xFFF7F7F7);
  static const textSecondary = Color(0xFF6B7280);
  static const textSecondaryDark = Color(0xFF9CA3AF);
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const userBubble = Color(0xFF196F77);
  static const aidaBubble = Color(0xFFE8F4F4);
  static const aidaBubbleDark = Color(0xFF1E3A3A);
}

class AidaTheme {
  static const double minFontSize = 16;
  static const double buttonRadius = 16;
  static const double cardRadius = 16;

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AidaColors.primary,
        secondary: AidaColors.accent,
        tertiary: AidaColors.gold,
        surface: AidaColors.surface,
        error: AidaColors.error,
      ),
      scaffoldBackgroundColor: AidaColors.surface,
      cardColor: AidaColors.card,
      textTheme: _textTheme(AidaColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AidaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AidaColors.primary,
        unselectedItemColor: AidaColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AidaColors.gold,
          foregroundColor: AidaColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 3,
          shadowColor: AidaColors.gold.withValues(alpha: 0.4),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: AidaColors.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: AidaColors.primary, width: 2),
        ),
        hintStyle: const TextStyle(fontSize: 16, color: AidaColors.textSecondary),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AidaColors.accent,
        secondary: AidaColors.accent,
        tertiary: AidaColors.gold,
        surface: AidaColors.surfaceDark,
        error: AidaColors.error,
      ),
      scaffoldBackgroundColor: AidaColors.surfaceDark,
      cardColor: AidaColors.cardDark,
      textTheme: _textTheme(AidaColors.textPrimaryDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: AidaColors.surfaceDark,
        foregroundColor: AidaColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AidaColors.textPrimaryDark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AidaColors.accent,
        unselectedItemColor: AidaColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AidaColors.surfaceDark,
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AidaColors.gold,
          foregroundColor: AidaColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 3,
          shadowColor: AidaColors.gold.withValues(alpha: 0.4),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AidaColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: AidaColors.accent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: const BorderSide(color: AidaColors.accent, width: 2),
        ),
        hintStyle: const TextStyle(fontSize: 16, color: AidaColors.textSecondaryDark),
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 18, color: color),
      bodyMedium: TextStyle(fontSize: 16, color: color),
      bodySmall: TextStyle(fontSize: 14, color: color),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color),
    );
  }
}
