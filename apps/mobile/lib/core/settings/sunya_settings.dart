import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunyaSettings {
  const SunyaSettings({
    this.name = 'Navneet',
    this.age,
    this.heightCm,
    this.weightKg,
    this.goal = 'Build a stronger, healthier baseline',
    this.glassOpacity = .55,
    this.glassBlur = 14,
    this.glassEnabled = true,
    this.themeMode = ThemeMode.system,
  });

  final String name;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String goal;
  final double glassOpacity;
  final double glassBlur;
  final bool glassEnabled;
  final ThemeMode themeMode;

  SunyaSettings copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    String? goal,
    double? glassOpacity,
    double? glassBlur,
    bool? glassEnabled,
    ThemeMode? themeMode,
  }) => SunyaSettings(
        name: name ?? this.name,
        age: age ?? this.age,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        goal: goal ?? this.goal,
        glassOpacity: glassOpacity ?? this.glassOpacity,
        glassBlur: glassBlur ?? this.glassBlur,
        glassEnabled: glassEnabled ?? this.glassEnabled,
        themeMode: themeMode ?? this.themeMode,
      );

  static ThemeMode _themeMode(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
}

final sunyaSettingsProvider =
    StateNotifierProvider<SunyaSettingsController, SunyaSettings>(
  (ref) => SunyaSettingsController()..load(),
);

class SunyaSettingsController extends StateNotifier<SunyaSettings> {
  SunyaSettingsController() : super(const SunyaSettings());

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final mode = p.getString('sunya.theme') ?? 'system';
    state = state.copyWith(
      name: p.getString('sunya.name') ?? state.name,
      age: p.getInt('sunya.age'),
      heightCm: p.getDouble('sunya.height'),
      weightKg: p.getDouble('sunya.weight'),
      goal: p.getString('sunya.goal') ?? state.goal,
      glassOpacity: p.getDouble('sunya.glassOpacity') ?? state.glassOpacity,
      glassBlur: p.getDouble('sunya.glassBlur') ?? state.glassBlur,
      glassEnabled: p.getBool('sunya.glassEnabled') ?? state.glassEnabled,
      themeMode: _themeMode(mode),
    );
  }

  Future<void> update(SunyaSettings next) async {
    state = next;
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString('sunya.name', next.name.trim()),
      if (next.age != null) p.setInt('sunya.age', next.age!) else p.remove('sunya.age'),
      if (next.heightCm != null) p.setDouble('sunya.height', next.heightCm!) else p.remove('sunya.height'),
      if (next.weightKg != null) p.setDouble('sunya.weight', next.weightKg!) else p.remove('sunya.weight'),
      p.setString('sunya.goal', next.goal.trim()),
      p.setDouble('sunya.glassOpacity', next.glassOpacity),
      p.setDouble('sunya.glassBlur', next.glassBlur),
      p.setBool('sunya.glassEnabled', next.glassEnabled),
      p.setString('sunya.theme', next.themeMode.name),
    ]);
  }

  Future<void> setVisual({
    double? opacity,
    double? blur,
    bool? enabled,
    ThemeMode? themeMode,
  }) => update(state.copyWith(
        glassOpacity: opacity,
        glassBlur: blur,
        glassEnabled: enabled,
        themeMode: themeMode,
      ));
}
