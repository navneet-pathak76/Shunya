import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_repository.dart';
import '../domain/entities/workout_session.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return InMemoryWorkoutRepository();
});

final workoutControllerProvider = StateNotifierProvider<WorkoutController, List<WorkoutSession>>((ref) {
  return WorkoutController(ref.read(workoutRepositoryProvider));
});

class WorkoutController extends StateNotifier<List<WorkoutSession>> {
  WorkoutController(this._repository) : super(const []) {
    state = _repository.getSessions();
  }

  final WorkoutRepository _repository;

  Future<void> addSet({
    required String exerciseName,
    required int repetitions,
    required double weightKg,
  }) async {
    final now = DateTime.now();
    final open = state.where((session) => session.endedAt == null).toList();
    final session = open.isNotEmpty
        ? open.last
        : WorkoutSession(startedAt: now);

    final updated = WorkoutSession(
      id: session.id,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      notes: session.notes,
      sets: [
        ...session.sets,
        WorkoutSet(
          exerciseName: exerciseName,
          repetitions: repetitions,
          weightKg: weightKg,
          completedAt: now,
        ),
      ],
    );

    await _repository.saveSession(updated);
    state = _repository.getSessions();
  }

  Future<void> finishCurrentSession() async {
    final open = state.where((session) => session.endedAt == null).toList();
    if (open.isEmpty) return;
    final session = open.last;
    await _repository.saveSession(
      WorkoutSession(
        id: session.id,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        notes: session.notes,
        sets: session.sets,
      ),
    );
    state = _repository.getSessions();
  }

  Future<void> deleteSession(String id) async {
    await _repository.deleteSession(id);
    state = _repository.getSessions();
  }
}
