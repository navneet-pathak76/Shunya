import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/database_provider.dart';
import '../data/appearance_repository.dart';
import '../domain/appearance_snapshot.dart';

final appearanceRepositoryProvider = FutureProvider<AppearanceRepository>(
  (ref) async => AppearanceRepository(
    await ref.watch(localRecordRepositoryProvider.future),
  ),
);

final appearanceProvider = StateNotifierProvider<AppearanceController,
    List<AppearanceSnapshot>>((ref) => AppearanceController(ref));

class AppearanceController extends StateNotifier<List<AppearanceSnapshot>> {
  AppearanceController(this.ref) : super(const []) {
    _load();
  }

  final Ref ref;

  Future<AppearanceRepository> get _repository =>
      ref.read(appearanceRepositoryProvider.future);

  Future<void> _load() async {
    state = await (await _repository).list();
  }

  Future<void> add({
    required String path,
    Uint8List? imageBytes,
    AppearanceArea area = AppearanceArea.face,
    String notes = '',
    double? userScore,
    double? hairDensityScore,
    double? beardCoverageScore,
    double? underEyeScore,
    double? skinClarityScore,
    double? hairShedding,
    bool? scalpItch,
    bool? scalpFlaking,
    double? sleepHours,
  }) async {
    final item = AppearanceSnapshot(
      id: const Uuid().v4(),
      capturedAt: DateTime.now().toUtc(),
      imagePath: path,
      imageDataBase64: imageBytes == null
          ? null
          : Uri.dataFromBytes(imageBytes, mimeType: 'image/jpeg').data,
      area: area,
      notes: notes,
      userScore: userScore,
      hairDensityScore: hairDensityScore,
      beardCoverageScore: beardCoverageScore,
      underEyeScore: underEyeScore,
      skinClarityScore: skinClarityScore,
      hairShedding: hairShedding,
      scalpItch: scalpItch,
      scalpFlaking: scalpFlaking,
      sleepHours: sleepHours,
    );

    final repository = await _repository;
    await repository.save(item);
    state = await repository.list();
  }

  Future<void> delete(String id) async {
    final repository = await _repository;
    await repository.delete(id);
    state = await repository.list();
  }
}
