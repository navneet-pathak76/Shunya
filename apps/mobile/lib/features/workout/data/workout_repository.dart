import 'dart:convert';

import '../../../core/providers/database_provider.dart';
import '../../../database/local_record_repository.dart';
import '../domain/entities/workout_session.dart';

abstract interface class WorkoutRepository {
  Future<List<WorkoutSession>> getSessions();
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String id);
}

/// Isar-backed repository. The domain model stays independent from Isar.
class LocalWorkoutRepository implements WorkoutRepository {
  LocalWorkoutRepository(this._records);
  final LocalRecordRepository _records;
  static const domain = 'workout.session';

  @override
  Future<List<WorkoutSession>> getSessions() async {
    final records = await _records.listDomain(domain);
    final sessions = <WorkoutSession>[];
    for (final record in records) {
      try {
        sessions.add(WorkoutSession.fromJson(jsonDecode(record.payload) as Map<String, dynamic>));
      } catch (_) {
        // Ignore malformed legacy records rather than breaking the workout screen.
      }
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  @override
  Future<void> saveSession(WorkoutSession session) => _records.upsert(
        domain,
        session.id,
        session.toJson(),
        recordDate: session.startedAt,
      );

  @override
  Future<void> deleteSession(String id) => _records.delete(domain, id);
}

final workoutRepositoryProvider = FutureProvider<WorkoutRepository>((ref) async {
  final database = await ref.watch(sunyaDatabaseProvider.future);
  return LocalWorkoutRepository(LocalRecordRepository(database));
});
