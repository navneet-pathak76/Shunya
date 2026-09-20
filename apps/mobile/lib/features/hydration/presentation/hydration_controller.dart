import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/database_provider.dart';
import '../data/hydration_repository.dart';
import '../domain/entities/hydration_entry.dart';

class HydrationState {
  const HydrationState({this.consumedMl = 0, this.goalMl = 2500});
  final int consumedMl;
  final int goalMl;
  double get progress => goalMl <= 0 ? 0 : (consumedMl / goalMl).clamp(0.0, 1.0).toDouble();
  HydrationState copyWith({int? consumedMl, int? goalMl}) => HydrationState(consumedMl: consumedMl ?? this.consumedMl, goalMl: goalMl ?? this.goalMl);
}

final hydrationRepositoryProvider = FutureProvider<HydrationRepository>((ref) async {
  final repo = await ref.watch(localRecordRepositoryProvider.future);
  return HydrationRepository(repo);
});

final hydrationProvider = StateNotifierProvider<HydrationController, HydrationState>((ref) => HydrationController(ref));

class HydrationController extends StateNotifier<HydrationState> {
  HydrationController(this.ref) : super(const HydrationState()) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final repository = await ref.read(hydrationRepositoryProvider.future);
    final today = DateTime.now().toUtc();
    final entries = await repository.listForDay(today);
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.amountMl);
    state = state.copyWith(consumedMl: total);
  }

  Future<void> add(int ml) async {
    final repository = await ref.read(hydrationRepositoryProvider.future);
    final entry = HydrationEntry(
      id: const Uuid().v4(),
      amountMl: ml,
      recordedAt: DateTime.now().toUtc(),
    );
    await repository.add(entry);
    await _load();
  }

  Future<void> reset() async {
    final repository = await ref.read(hydrationRepositoryProvider.future);
    final today = DateTime.now().toUtc();
    final entries = await repository.listForDay(today);
    for (final entry in entries) {
      await repository.delete(entry.id);
    }
    state = state.copyWith(consumedMl: 0);
  }
}
