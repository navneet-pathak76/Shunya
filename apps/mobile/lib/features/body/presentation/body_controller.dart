import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/database_provider.dart';
import '../data/body_repository.dart';
import '../domain/entities/body_measurement.dart';
import '../domain/entities/body_profile.dart';

class BodyState {
  const BodyState({
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.profile,
    this.measurements = const [],
  });

  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final BodyProfile? profile;
  final List<BodyMeasurement> measurements;

  double? get bmi {
    final weight = weightKg;
    final height = heightCm;
    if (weight == null || height == null || height <= 0) return null;
    final metres = height / 100;
    return weight / (metres * metres);
  }

  BodyState copyWith({
    double? weightKg,
    double? heightCm,
    double? bodyFatPercent,
    BodyProfile? profile,
    List<BodyMeasurement>? measurements,
  }) =>
      BodyState(
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
        profile: profile ?? this.profile,
        measurements: measurements ?? this.measurements,
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
    final profile = await repository.loadProfile();
    final measurements = await repository.listAll();

    state = BodyState(
      weightKg: latest?.weightKg,
      heightCm: profile?.heightCm ?? latest?.heightCm,
      bodyFatPercent: profile?.bodyFatPercent ?? latest?.bodyFatPercent,
      profile: profile,
      measurements: measurements,
    );
  }

  Future<void> save({
    double? weightKg,
    double? heightCm,
    double? bodyFatPercent,
  }) async {
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
    final measurements = [...current.measurements, next]
      ..sort((a, b) => a.date.compareTo(b.date));

    state = BodyState(
      weightKg: next.weightKg == 0 ? current.weightKg : next.weightKg,
      heightCm: next.heightCm == 0 ? current.heightCm : next.heightCm,
      bodyFatPercent: next.bodyFatPercent == 0 ? current.bodyFatPercent : next.bodyFatPercent,
      profile: current.profile,
      measurements: measurements,
    );
  }

  Future<void> saveProfile(BodyProfile profile) async {
    final repository = await ref.read(bodyRepositoryProvider.future);
    await repository.saveProfile(profile);
    state = state.copyWith(
      heightCm: profile.heightCm,
      bodyFatPercent: profile.bodyFatPercent,
      profile: profile,
    );
  }
}
