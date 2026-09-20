import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'sunya_record.dart';

/// Web persistence implementation using browser-local storage.
class SunyaDatabase {
  SunyaDatabase._(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'sunya_records';

  static Future<SunyaDatabase> open() async {
    return SunyaDatabase._(await SharedPreferences.getInstance());
  }

  Future<void> close() async {}

  Future<T> write<T>(Future<T> Function() operation) async => operation();

  Future<List<SunyaRecord>> listAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((entry) => SunyaRecord.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }

  Future<void> put(SunyaRecord record) async {
    final items = await listAll();
    final index = items.indexWhere((item) => item.domain == record.domain && item.key == record.key);
    if (index >= 0) {
      items[index] = record;
    } else {
      items.add(record);
    }
    await _prefs.setString(_key, jsonEncode(items.map((item) => item.toJson()).toList()));
  }
}
