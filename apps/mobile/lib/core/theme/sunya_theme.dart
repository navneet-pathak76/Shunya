import 'package:flutter/material.dart';

class SunyaTheme {
  SunyaTheme._();

  static const gold = Color(0xFFD4AF37);
  static const goldBright = Color(0xFFF0C75E);
  static const goldSoft = Color(0x26D4AF37);
  static const goldGlow = Color(0xFFF8D98B);
  static const ivory = Color(0xFFF5F5F5);

  // Legacy aliases keep existing feature widgets on the SUNYA brand palette.
  static const blue = gold;
  static const blueBright = goldBright;
  static const blueSoft = goldSoft;
  static const blueBrightSoft = Color(0x33F0C75E);
  static const blueGlow = goldGlow;
  static const orange = goldBright;
  static const orangeSoft = goldSoft;

  static const background = Color(0x00000000);
  static const border = Color(0x26D4AF37);

  static const darkBackground = Color(0xFF050608);
  static const darkSurface = Color(0xFF0D1015);
  static const darkSurfaceElevated = Color(0xFF151922);
  static const darkText = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFFC5C5C5);
  static const darkTextMuted = Color(0xFF858585);

  static const lightSurface = Color(0xFFFAFAF8);
  static const lightText = Color(0xFF111111);
  static const lightTextSecondary = Color(0xFF555555);
  static const lightTextMuted = Color(0xFF777777);

  static const success = Color(0xFF35B87A);
  static const warning = goldBright;
  static const error = Color(0xFFE05B5B);
  static const info = gold;
  static const sleep = Color(0xFF8C7BFF);
  static const nutrition = Color(0xFF73B87A);
  static const hydration = Color(0xFF69A9FF);

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
          primary: gold,
          secondary: goldBright,
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
        ),
        cardTheme: CardThemeData(
          color: lightSurface.withOpacity(.90),
          elevation: 0,
          margin: EdgeInsets.zero,
          shadowColor: gold.withOpacity(.16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: BorderSide(color: gold.withOpacity(.18)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightSurface.withOpacity(.92),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: gold.withOpacity(.18)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: gold.withOpacity(.18)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: gold, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: lightSurface.withOpacity(.96),
          elevation: 0,
          indicatorColor: goldSoft,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: lightText),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: gold),
        dividerTheme: DividerThemeData(color: gold.withOpacity(.14), thickness: 1),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          surface: darkSurface,
          primary: goldBright,
          secondary: gold,
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
        cardTheme: CardThemeData(
          color: darkSurface.withOpacity(.84),
          elevation: 0,
          margin: EdgeInsets.zero,
          shadowColor: gold.withOpacity(.20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: BorderSide(color: gold.withOpacity(.15)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: darkSurface.withOpacity(.82),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: gold.withOpacity(.16)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: BorderSide(color: gold.withOpacity(.16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: goldBright, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkBackground.withOpacity(.96),
          elevation: 0,
          indicatorColor: goldSoft,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: darkText),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: goldBright),
        dividerTheme: DividerThemeData(color: gold.withOpacity(.14), thickness: 1),
      );

  static LinearGradient backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8F7F2), Color(0xFFFFFFFF), Color(0xFFF1E8CE)],
        stops: [0.0, 0.58, 1.0],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF000000), Color(0xFF050608), Color(0xFF111A2A)],
      stops: [0.0, 0.58, 1.0],
    );
  }
}
