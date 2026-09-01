import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStore> create() async {
    return LocalStore(await SharedPreferences.getInstance());
  }

  Future<void> writeJson(String key, Object value) async {
    await _preferences.setString(key, jsonEncode(value));
  }

  T? readJson<T>(String key, T Function(Object value) parser) {
    final raw = _preferences.getString(key);
    if (raw == null) return null;
    try {
      return parser(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) => _preferences.remove(key);
}
