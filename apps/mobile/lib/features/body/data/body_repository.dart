import 'dart:convert';

import '../../../database/local_record_repository.dart';
import '../domain/entities/body_measurement.dart';
import '../domain/entities/body_profile.dart';
import '../domain/entities/body_region_measurement.dart';

class BodyRepository {
  BodyRepository(this._localRepository);

  final LocalRecordRepository _localRepository;

  static const String measurementDomain = 'body_measurement';
  static const String profileDomain = 'body_profile';
  static const String regionDomain = 'body_region';
  static const String profileKey = 'profile';

  Future<List<BodyMeasurement>> listAll() async {
    final records = await _localRepository.listDomain(measurementDomain);
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
      domain: measurementDomain,
      key: measurement.id,
      payload: measurement.toJson(),
      recordDate: measurement.date,
    );
  }

  Future<void> delete(String id) async {
    await _localRepository.delete(measurementDomain, id);
  }

  Future<BodyProfile?> loadProfile() async {
    final payload = await _localRepository.readPayload(profileDomain, profileKey);
    return payload == null ? null : BodyProfile.fromJson(payload);
  }

  Future<void> saveProfile(BodyProfile profile) async {
    await _localRepository.upsert(
      domain: profileDomain,
      key: profileKey,
      payload: profile.toJson(),
      recordDate: profile.updatedAt,
    );
  }

  Future<List<BodyRegionMeasurement>> listRegions() async {
    final records = await _localRepository.listDomain(regionDomain);
    final items = <BodyRegionMeasurement>[];
    for (final record in records) {
      final payload = jsonDecode(record.payload) as Map<String, dynamic>;
      items.add(BodyRegionMeasurement.fromJson(payload));
    }
    items.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return items;
  }

  Future<void> saveRegion(BodyRegionMeasurement measurement) async {
    await _localRepository.upsert(
      domain: regionDomain,
      key: measurement.id,
      payload: measurement.toJson(),
      recordDate: measurement.recordedAt,
    );
  }
}
