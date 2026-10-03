import 'package:health/health.dart';

class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({
    this.steps = 0,
    this.activeCalories = 0,
    this.totalCalories = 0,
    this.waterMl = 0,
    this.weightKg,
    this.heartRate,
    this.restingHeartRate,
    this.hrv,
    this.oxygen,
    this.sleepHours = 0,
    this.records = 0,
    this.source = 'Health platform',
  });

  final int steps;
  final double activeCalories;
  final double totalCalories;
  final double waterMl;
  final double? weightKg;
  final double? heartRate;
  final double? restingHeartRate;
  final double? hrv;
  final double? oxygen;
  final double sleepHours;
  final int records;
  final String source;
}

class SunyaHealthConnectService {
  final Health _health = Health();

  static const requestedTypes = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WATER,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
    HealthDataType.NUTRITION,
  ];

  Future<void> configure() => _health.configure();

  Future<List<HealthDataType>> _availableTypes() async {
    await _health.configure();
    final result = <HealthDataType>[];
    for (final type in requestedTypes) {
      try {
        if (await _health.isDataTypeAvailable(type)) {
          result.add(type);
        }
      } catch (_) {
        // Some Android Health Connect versions reject individual types.
        // SUNYA skips those types instead of failing the complete connection.
      }
    }
    return result;
  }

  Future<bool> requestReadAccess() async {
    final types = await _availableTypes();
    if (types.isEmpty) return false;
    return _health.requestAuthorization(
      types,
      permissions: List.filled(types.length, HealthDataAccess.READ),
    );
  }

  Future<bool> get available async => (await _availableTypes()).isNotEmpty;

  Future<SunyaHealthSnapshot> sync({int days = 7}) async {
    final types = await _availableTypes();
    if (types.isEmpty) {
      return const SunyaHealthSnapshot(source: 'Health Connect');
    }

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final points = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    double sum(HealthDataType type) => points
        .where((p) => p.type == type)
        .map((p) => p.value)
        .whereType<NumericHealthValue>()
        .fold(0, (a, b) => a + b.numericValue.toDouble());

    double? average(HealthDataType type) {
      final values = points
          .where((p) => p.type == type)
          .map((p) => p.value)
          .whereType<NumericHealthValue>()
          .map((v) => v.numericValue.toDouble())
          .toList();
      if (values.isEmpty) return null;
      return values.reduce((a, b) => a + b) / values.length;
    }

    final sleep = points
        .where((p) => p.type == HealthDataType.SLEEP_SESSION)
        .fold<double>(
          0,
          (a, p) => a + p.dateTo.difference(p.dateFrom).inMinutes / 60,
        );

    final weights = points.where((p) => p.type == HealthDataType.WEIGHT).toList();
    final latest = weights.isEmpty
        ? null
        : weights.reduce((a, b) => a.dateTo.isAfter(b.dateTo) ? a : b);

    return SunyaHealthSnapshot(
      steps: sum(HealthDataType.STEPS).round(),
      activeCalories: sum(HealthDataType.ACTIVE_ENERGY_BURNED),
      totalCalories: sum(HealthDataType.TOTAL_CALORIES_BURNED),
      waterMl: sum(HealthDataType.WATER),
      weightKg: latest?.value is NumericHealthValue
          ? (latest!.value as NumericHealthValue).numericValue.toDouble()
          : null,
      heartRate: average(HealthDataType.HEART_RATE),
      restingHeartRate: average(HealthDataType.RESTING_HEART_RATE),
      hrv: average(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      oxygen: average(HealthDataType.BLOOD_OXYGEN),
      sleepHours: sleep,
      records: points.length,
      source: _health.platformType.name,
    );
  }
}
