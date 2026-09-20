import 'dart:convert';

import 'package:isar/isar.dart';

import 'database.dart';
import 'sunya_record.dart';

/// Small persistence API shared by feature repositories.
///
/// Feature code stores typed JSON payloads here while the Isar schema remains
/// stable. Domain-specific repositories should own serialization and validation.
class LocalRecordRepository {
  LocalRecordRepository(this.database);

  final SunyaDatabase database;

  Future<SunyaRecord?> find(String domain, String key) async {
    final records = await database.records.where().findAll();
    for (final record in records) {
      if (!record.deleted && record.domain == domain && record.key == key) {
        return record;
      }
    }
    return null;
  }

  Future<SunyaRecord> upsert({
    required String domain,
    required String key,
    required Map<String, dynamic> payload,
    DateTime? recordDate,
  }) async {
    final now = DateTime.now().toUtc();
    final existing = await find(domain, key);
    final record = existing ?? SunyaRecord();

    record.domain = domain;
    record.key = key;
    record.payload = jsonEncode(payload);
    record.recordDate = recordDate?.toUtc();
    record.createdAt = existing?.createdAt ?? now;
    record.updatedAt = now;
    record.version = (existing?.version ?? 0) + 1;
    record.deleted = false;

    await database.write(() async {
      await database.records.put(record);
    });
    return record;
  }

  Future<Map<String, dynamic>?> readPayload(String domain, String key) async {
    final record = await find(domain, key);
    if (record == null) return null;
    return Map<String, dynamic>.from(jsonDecode(record.payload) as Map);
  }

  Future<void> delete(String domain, String key) async {
    final record = await find(domain, key);
    if (record == null) return;
    record.deleted = true;
    record.updatedAt = DateTime.now().toUtc();
    record.version += 1;
    await database.write(() async {
      await database.records.put(record);
    });
  }

  Future<List<SunyaRecord>> listDomain(String domain) async {
    final records = await database.records.where().findAll();
    return records
        .where((record) => record.domain == domain && !record.deleted)
        .toList(growable: false);
  }
}
