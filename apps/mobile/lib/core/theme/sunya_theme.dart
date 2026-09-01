import 'package:flutter/material.dart';

class SunyaTheme {
  SunyaTheme._();

  static const background = Color(0xFF080808);
  static const surface = Color(0xFF121212);
  static const gold = Color(0xFFD9A441);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: gold,
          secondary: gold,
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: gold),
      );
}
