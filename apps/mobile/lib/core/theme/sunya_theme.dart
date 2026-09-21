import 'package:flutter/material.dart';

/// SUNYA visual system.
/// Light: white surfaces with restrained blue lighting.
/// Dark: black surfaces with restrained blue lighting.
/// Feature UI should consume Theme.of(context).colorScheme where possible.
class SunyaTheme {
  SunyaTheme._();

  static const blue = Color(0xFF2563EB);
  static const blueBright = Color(0xFF3B82F6);
  static const blueSoft = Color(0x332563EB);
  static const blueGlow = Color(0xFF60A5FA);

  static const darkBackground = Color(0xFF020617);
  static const darkSurface = Color(0xFF0B1220);
  static const darkText = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFB6C2D1);
  static const darkTextMuted = Color(0xFF718096);

  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextMuted = Color(0xFF64748B);

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const sleep = Color(0xFF7C3AED);
  static const nutrition = Color(0xFF16A34A);
  static const hydration = Color(0xFF2563EB);

  static const radiusSmall = 12.0;
  static const radiusMedium = 18.0;
  static const radiusLarge = 24.0;
  static const radiusPill = 999.0;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.light(
          surface: lightSurface,
          primary: blue,
          secondary: blueBright,
          error: error,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: lightText),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: lightText),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: lightText),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: lightText),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightText),
          bodyLarge: TextStyle(fontSize: 16, color: lightText),
          bodyMedium: TextStyle(fontSize: 14, color: lightTextSecondary),
          bodySmall: TextStyle(fontSize: 12, color: lightTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: lightText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: lightText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: lightSurface.withOpacity(.86),
          elevation: 0,
          margin: EdgeInsets.zero,
          shadowColor: blue.withOpacity(.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: BorderSide(color: blue.withOpacity(.10)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface.withOpacity(.82),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: blue.withOpacity(.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: blue.withOpacity(.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: lightSurface.withOpacity(.94),
          elevation: 0,
          shadowColor: blue.withOpacity(.16),
          indicatorColor: blueSoft,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: lightText),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: blue),
        dividerTheme: DividerThemeData(color: blue.withOpacity(.10), thickness: 1),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          surface: darkSurface,
          primary: blueBright,
          secondary: blueGlow,
          error: error,
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: darkText),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: darkText),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: darkText),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: darkText),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkText),
          bodyLarge: TextStyle(fontSize: 16, color: darkText),
          bodyMedium: TextStyle(fontSize: 14, color: darkTextSecondary),
          bodySmall: TextStyle(fontSize: 12, color: darkTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: darkText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardTheme(
          color: darkSurface.withOpacity(.82),
          elevation: 0,
          margin: EdgeInsets.zero,
          shadowColor: blue.withOpacity(.24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: BorderSide(color: blue.withOpacity(.16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface.withOpacity(.76),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: blue.withOpacity(.16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: blue.withOpacity(.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: blueBright, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkBackground.withOpacity(.94),
          elevation: 0,
          shadowColor: blue.withOpacity(.30),
          indicatorColor: blueSoft,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: darkText),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: blueBright),
        dividerTheme: DividerThemeData(color: blue.withOpacity(.14), thickness: 1),
      );

  static LinearGradient backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF), Color(0xFFEFF6FF)],
        stops: [0.0, 0.58, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF000000), Color(0xFF020617), Color(0xFF07142F)],
      stops: [0.0, 0.58, 1.0],
    );
  }
}
