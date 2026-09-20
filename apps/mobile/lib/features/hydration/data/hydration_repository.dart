import 'dart:convert';

import '../../../database/local_record_repository.dart';
import '../domain/entities/hydration_entry.dart';

class HydrationRepository {
  HydrationRepository(this._localRepository);

  final LocalRecordRepository _localRepository;

  static const String domain = 'hydration';

  Future<List<HydrationEntry>> listAll() async {
    final records = await _localRepository.listDomain(domain);
    final items = <HydrationEntry>[];
    for (final record in records) {
      final payload = jsonDecode(record.payload) as Map<String, dynamic>;
      items.add(HydrationEntry.fromJson(payload));
    }
    items.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return items;
  }

  Future<List<HydrationEntry>> listForDay(DateTime day) async {
    final start = DateTime.utc(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final entries = await listAll();
    return entries.where((entry) {
      final recorded = entry.recordedAt.toUtc();
      return recorded.isAfter(start) && recorded.isBefore(end);
    }).toList();
  }

  Future<void> add(HydrationEntry entry) async {
    await _localRepository.upsert(
      domain: domain,
      key: entry.id,
      payload: entry.toJson(),
      recordDate: entry.recordedAt,
    );
  }

  Future<void> delete(String id) async {
    await _localRepository.delete(domain, id);
  }
}
