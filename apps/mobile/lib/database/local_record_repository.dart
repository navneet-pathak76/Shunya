import 'dart:convert';

import 'database.dart';
import 'sunya_record.dart';

/// Shared local-first persistence API used by feature repositories.
/// Native builds use Isar; web builds use persistent browser storage.
class LocalRecordRepository {
  LocalRecordRepository(this.database);

  final SunyaDatabase database;

  Future<SunyaRecord?> find(String domain, String key) async {
    final records = await database.listAll();
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
    final record = (existing ?? SunyaRecord(domain: domain, key: key, payload: ''))
        .copyWith(
      domain: domain,
      key: key,
      payload: jsonEncode(payload),
      recordDate: recordDate?.toUtc(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      version: (existing?.version ?? 0) + 1,
      deleted: false,
    );

    await database.put(record);
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
    final updated = record.copyWith(
      deleted: true,
      updatedAt: DateTime.now().toUtc(),
      version: record.version + 1,
    );
    await database.put(updated);
  }

  Future<List<SunyaRecord>> listDomain(String domain) async {
    final records = await database.listAll();
    return records
        .where((record) => record.domain == domain && !record.deleted)
        .toList(growable: false);
  }
}
