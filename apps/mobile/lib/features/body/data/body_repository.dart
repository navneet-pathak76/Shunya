import 'dart:convert';

import '../../../database/local_record_repository.dart';
import '../domain/entities/body_measurement.dart';

class BodyRepository {
  BodyRepository(this._localRepository);

  final LocalRecordRepository _localRepository;

  static const String domain = 'body';

  Future<List<BodyMeasurement>> listAll() async {
    final records = await _localRepository.listDomain(domain);
    final items = <BodyMeasurement>[];
    for (final record in records) {
      final payload = jsonDecode(record.payload) as Map<String, dynamic>;
      items.add(BodyMeasurement.fromJson(payload));
    }
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Future<BodyMeasurement?> latest() async {
    final items = await listAll();
    if (items.isEmpty) return null;
    return items.last;
  }

  Future<void> save(BodyMeasurement measurement) async {
    await _localRepository.upsert(
      domain: domain,
      key: measurement.id,
      payload: measurement.toJson(),
      recordDate: measurement.date,
    );
  }

  Future<void> delete(String id) async {
    await _localRepository.delete(domain, id);
  }
}
