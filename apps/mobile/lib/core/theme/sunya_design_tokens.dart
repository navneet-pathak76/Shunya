import 'package:flutter/material.dart';

/// Central SUNYA visual tokens. Keep feature screens independent of a fixed accent.
class SunyaDesignTokens {
  const SunyaDesignTokens._();

  static const accent = Color(0xFFFF7A1A);
  static const background = Color(0xFF080808);
  static const surface = Color(0xFF141414);
  static const glass = Color(0x331FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFF9A9A9A);

  static ThemeData theme({Color accentColor = accent}) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      surface: surface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withValues(alpha: .72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
