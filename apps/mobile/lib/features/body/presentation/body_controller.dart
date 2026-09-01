import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/storage_provider.dart';

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

final bodyProvider = StateNotifierProvider<BodyController, BodyState>((ref) => BodyController(ref));

class BodyController extends StateNotifier<BodyState> {
  BodyController(this.ref) : super(const BodyState()) { _load(); }
  final Ref ref;

  Future<void> _load() async {
    final storage = await ref.read(storageProvider.future);
    final weight = storage.getDouble('body.weight_kg');
    final height = storage.getDouble('body.height_cm');
    final fat = storage.getDouble('body.fat_percent');
    state = BodyState(
      weightKg: weight == 0 ? null : weight,
      heightCm: height == 0 ? null : height,
      bodyFatPercent: fat == 0 ? null : fat,
    );
  }

  Future<void> save({double? weightKg, double? heightCm, double? bodyFatPercent}) async {
    final next = BodyState(
      weightKg: weightKg ?? state.weightKg,
      heightCm: heightCm ?? state.heightCm,
      bodyFatPercent: bodyFatPercent ?? state.bodyFatPercent,
    );
    state = next;
    final storage = await ref.read(storageProvider.future);
    if (next.weightKg != null) await storage.setDouble('body.weight_kg', next.weightKg!);
    if (next.heightCm != null) await storage.setDouble('body.height_cm', next.heightCm!);
    if (next.bodyFatPercent != null) await storage.setDouble('body.fat_percent', next.bodyFatPercent!);
  }
}
