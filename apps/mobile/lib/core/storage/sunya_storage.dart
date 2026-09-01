import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SunyaStorage {
  SunyaStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<SunyaStorage> open() async => SunyaStorage(await SharedPreferences.getInstance());

  List<Map<String, dynamic>> readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));

  double getDouble(String key, {double fallback = 0}) => _prefs.getDouble(key) ?? fallback;
  int getInt(String key, {int fallback = 0}) => _prefs.getInt(key) ?? fallback;
  String getString(String key, {String fallback = ''}) => _prefs.getString(key) ?? fallback;
  bool getBool(String key, {bool fallback = false}) => _prefs.getBool(key) ?? fallback;

  Future<void> setDouble(String key, double value) => _prefs.setDouble(key, value);
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
}
