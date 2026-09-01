import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/storage_provider.dart';

class HydrationState {
  const HydrationState({this.consumedMl = 0, this.goalMl = 2500});
  final int consumedMl;
  final int goalMl;
  double get progress => goalMl <= 0 ? 0 : (consumedMl / goalMl).clamp(0.0, 1.0).toDouble();
  HydrationState copyWith({int? consumedMl, int? goalMl}) => HydrationState(consumedMl: consumedMl ?? this.consumedMl, goalMl: goalMl ?? this.goalMl);
}

final hydrationProvider = StateNotifierProvider<HydrationController, HydrationState>((ref) => HydrationController(ref));

class HydrationController extends StateNotifier<HydrationState> {
  HydrationController(this.ref) : super(const HydrationState()) { _load(); }
  final Ref ref;
  static const _key = 'hydration.today.ml';

  Future<void> _load() async {
    final storage = await ref.read(storageProvider.future);
    state = state.copyWith(consumedMl: storage.getInt(_key));
  }

  Future<void> add(int ml) async {
    final next = (state.consumedMl + ml).clamp(0, 100000);
    state = state.copyWith(consumedMl: next);
    final storage = await ref.read(storageProvider.future);
    await storage.setInt(_key, next);
  }

  Future<void> reset() async {
    state = state.copyWith(consumedMl: 0);
    final storage = await ref.read(storageProvider.future);
    await storage.setInt(_key, 0);
  }
}
