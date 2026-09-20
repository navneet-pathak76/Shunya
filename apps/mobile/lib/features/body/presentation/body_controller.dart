import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/database_provider.dart';
import '../data/body_repository.dart';
import '../domain/entities/body_measurement.dart';
import '../domain/entities/body_profile.dart';
import '../domain/entities/body_region_measurement.dart';

class BodyState {
  const BodyState({
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.profile,
    this.measurements = const [],
    this.regionMeasurements = const [],
  });

  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final BodyProfile? profile;
  final List<BodyMeasurement> measurements;
  final List<BodyRegionMeasurement> regionMeasurements;

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
    List<BodyRegionMeasurement>? regionMeasurements,
  }) =>
      BodyState(
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
        profile: profile ?? this.profile,
        measurements: measurements ?? this.measurements,
        regionMeasurements: regionMeasurements ?? this.regionMeasurements,
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
    final regionMeasurements = await repository.listRegions();

    state = BodyState(
      weightKg: latest?.weightKg,
      heightCm: profile?.heightCm ?? latest?.heightCm,
      bodyFatPercent: profile?.bodyFatPercent ?? latest?.bodyFatPercent,
      profile: profile,
      measurements: measurements,
      regionMeasurements: regionMeasurements,
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

    state = state.copyWith(
      weightKg: next.weightKg == 0 ? current.weightKg : next.weightKg,
      heightCm: next.heightCm == 0 ? current.heightCm : next.heightCm,
      bodyFatPercent: next.bodyFatPercent == 0 ? current.bodyFatPercent : next.bodyFatPercent,
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

  Future<void> saveRegion({
    required BodyRegion region,
    required double centimetres,
    String note = '',
  }) async {
    final repository = await ref.read(bodyRepositoryProvider.future);
    final measurement = BodyRegionMeasurement(
      id: const Uuid().v4(),
      region: region,
      centimetres: centimetres,
      recordedAt: DateTime.now().toUtc(),
      note: note,
    );
    await repository.saveRegion(measurement);

    state = state.copyWith(
      regionMeasurements: [...state.regionMeasurements, measurement]
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)),
    );
  }
}
