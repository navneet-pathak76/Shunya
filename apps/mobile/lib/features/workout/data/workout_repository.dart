import 'dart:convert';

import '../../../database/local_record_repository.dart';
import '../domain/entities/workout_session.dart';

abstract interface class WorkoutRepository {
  Future<List<WorkoutSession>> getSessions();
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String id);
}

class LocalWorkoutRepository implements WorkoutRepository {
  LocalWorkoutRepository(this._localRepository);

  final LocalRecordRepository _localRepository;
  static const domain = 'workout';

  @override
  Future<List<WorkoutSession>> getSessions() async {
    final records = await _localRepository.listDomain(domain);
    final sessions = records.map((record) {
      return WorkoutSession.fromJson(jsonDecode(record.payload) as Map<String, dynamic>);
    }).toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<void> saveSession(WorkoutSession session) {
    return _localRepository.upsert(
      domain: domain,
      key: session.id,
      payload: session.toJson(),
      recordDate: session.startedAt,
    );
  }

  @override
  Future<void> deleteSession(String id) {
    return _localRepository.delete(domain, id);
  }
}
