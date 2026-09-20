import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/database_provider.dart';
import '../data/body_repository.dart';
import '../domain/entities/body_measurement.dart';

class BodyState {
  const BodyState({this.weightKg, this.heightCm, this.bodyFatPercent});
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;

  double? get bmi {
    final weight = weightKg;
    final height = heightCm;
    if (weight == null || height == null || height <= 0) return null;
    final metres = height / 100;
    return weight / (metres * metres);
  }

  BodyState copyWith({double? weightKg, double? heightCm, double? bodyFatPercent}) => BodyState(
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      );
}

final bodyRepositoryProvider = FutureProvider<BodyRepository>((ref) async {
  final repo = await ref.watch(localRecordRepositoryProvider.future);
  return BodyRepository(repo);
});

final bodyProvider = StateNotifierProvider<BodyController, BodyState>((ref) => BodyController(ref));

class BodyController extends StateNotifier<BodyState> {
  BodyController(this.ref) : super(const BodyState()) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final repository = await ref.read(bodyRepositoryProvider.future);
    final latest = await repository.latest();
    if (latest == null) {
      state = const BodyState();
      return;
    }

    state = BodyState(
      weightKg: latest.weightKg,
      heightCm: latest.heightCm,
      bodyFatPercent: latest.bodyFatPercent,
    );
  }

  Future<void> save({double? weightKg, double? heightCm, double? bodyFatPercent}) async {
    final repository = await ref.read(bodyRepositoryProvider.future);
    final current = state;
    final next = BodyMeasurement(
      id: const Uuid().v4(),
      date: DateTime.now().toUtc(),
      weightKg: weightKg ?? current.weightKg ?? 0,
      heightCm: heightCm ?? current.heightCm ?? 0,
      bodyFatPercent: bodyFatPercent ?? current.bodyFatPercent ?? 0,
    );

    await repository.save(next);
    state = BodyState(
      weightKg: next.weightKg == 0 ? current.weightKg : next.weightKg,
      heightCm: next.heightCm == 0 ? current.heightCm : next.heightCm,
      bodyFatPercent: next.bodyFatPercent == 0 ? current.bodyFatPercent : next.bodyFatPercent,
    );
  }
}
