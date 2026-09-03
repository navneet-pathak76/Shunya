import '../domain/entities/workout_session.dart';

abstract interface class WorkoutRepository {
  List<WorkoutSession> getSessions();
  Future<void> saveSession(WorkoutSession session);
  Future<void> deleteSession(String id);
}

class InMemoryWorkoutRepository implements WorkoutRepository {
  final List<WorkoutSession> _sessions = [];

  @override
  List<WorkoutSession> getSessions() => List.unmodifiable(_sessions);

  @override
  Future<void> saveSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index == -1) {
      _sessions.add(session);
    } else {
      _sessions[index] = session;
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((item) => item.id == id);
  }
}
