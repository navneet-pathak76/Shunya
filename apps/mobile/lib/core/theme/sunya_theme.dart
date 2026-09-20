import 'package:flutter/material.dart';

/// SUNYA visual system: dark-first, glass surfaces, orange launch accent.
/// All feature UI should consume these tokens instead of hard-coded colors.
class SunyaTheme {
  SunyaTheme._();

  static const background = Color(0xFF07090B);
  static const backgroundElevated = Color(0xFF0B0F12);
  static const surface = Color(0xFF11161A);
  static const surfaceElevated = Color(0xFF171D22);
  static const glass = Color(0x661A2025);
  static const glassStrong = Color(0xB3141A1F);
  static const border = Color(0x26FFFFFF);
  static const borderStrong = Color(0x40FFFFFF);
  static const textPrimary = Color(0xFFF5F7F8);
  static const textSecondary = Color(0xFFA8B0B6);
  static const textMuted = Color(0xFF707980);

  static const orange = Color(0xFFFF5A1F);
  static const orangeBright = Color(0xFFFF6B2C);
  static const orangeSoft = Color(0x33FF5A1F);
  static const orangeDeep = Color(0xFFCC3F10);

  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFFF5C5C);
  static const info = Color(0xFF60A5FA);
  static const sleep = Color(0xFF9B8AFB);
  static const nutrition = Color(0xFF4ADE80);
  static const hydration = Color(0xFF60A5FA);

  static const radiusSmall = 12.0;
  static const radiusMedium = 18.0;
  static const radiusLarge = 24.0;
  static const radiusPill = 999.0;

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: orange,
          secondary: orangeBright,
          error: error,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: textPrimary),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: textPrimary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: glassStrong,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: glass,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: orange),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xE60B0D0F),
          elevation: 0,
          indicatorColor: orangeSoft,
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: orange),
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
      );
}
