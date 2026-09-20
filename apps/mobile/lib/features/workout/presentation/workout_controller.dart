import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../data/workout_repository.dart';
import '../domain/entities/workout_session.dart';

final workoutRepositoryProvider = FutureProvider<WorkoutRepository>((ref) async {
  final local = await ref.watch(localRecordRepositoryProvider.future);
  return LocalWorkoutRepository(local);
});

final workoutControllerProvider = StateNotifierProvider<WorkoutController, List<WorkoutSession>>(
  (ref) => WorkoutController(ref),
);

class WorkoutController extends StateNotifier<List<WorkoutSession>> {
  WorkoutController(this.ref) : super(const []) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final repository = await ref.read(workoutRepositoryProvider.future);
    state = await repository.getSessions();
  }

  Future<void> addSet({
    required String exerciseName,
    required int repetitions,
    required double weightKg,
  }) async {
    final repository = await ref.read(workoutRepositoryProvider.future);
    final now = DateTime.now().toUtc();
    final open = state.where((session) => session.endedAt == null).toList();
    final session = open.isNotEmpty ? open.last : WorkoutSession(startedAt: now);

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

    await repository.saveSession(updated);
    state = await repository.getSessions();
  }

  Future<void> finishCurrentSession() async {
    final repository = await ref.read(workoutRepositoryProvider.future);
    final open = state.where((session) => session.endedAt == null).toList();
    if (open.isEmpty) return;
    final session = open.last;

    await repository.saveSession(
      WorkoutSession(
        id: session.id,
        startedAt: session.startedAt,
        endedAt: DateTime.now().toUtc(),
        notes: session.notes,
        sets: session.sets,
      ),
    );
    state = await repository.getSessions();
  }

  Future<void> deleteSession(String id) async {
    final repository = await ref.read(workoutRepositoryProvider.future);
    await repository.deleteSession(id);
    state = await repository.getSessions();
  }
}
