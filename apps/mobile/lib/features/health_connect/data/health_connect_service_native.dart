import 'package:health/health.dart';

class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({
    this.steps = 0,
    this.activeCalories = 0,
    this.totalCalories = 0,
    this.waterMl = 0,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.bmi,
    this.heartRate,
    this.restingHeartRate,
    this.hrv,
    this.oxygen,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.glucoseMgDl,
    this.temperatureC,
    this.respiratoryRate,
    this.sleepHours = 0,
    this.records = 0,
    this.sources = const [],
    this.source = 'Health Connect',
  });

  final int steps;
  final double activeCalories;
  final double totalCalories;
  final double waterMl;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? bmi;
  final double? heartRate;
  final double? restingHeartRate;
  final double? hrv;
  final double? oxygen;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? glucoseMgDl;
  final double? temperatureC;
  final double? respiratoryRate;
  final double sleepHours;
  final int records;
  final List<String> sources;
  final String source;

  Map<String, dynamic> toContext() => {
    'steps': steps,
    'activeCalories': activeCalories,
    'totalCalories': totalCalories,
    'waterMl': waterMl,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bodyFatPercent': bodyFatPercent,
    'bmi': bmi,
    'heartRate': heartRate,
    'restingHeartRate': restingHeartRate,
    'hrv': hrv,
    'spo2': oxygen,
    'bloodPressure': {
      'systolic': bloodPressureSystolic,
      'diastolic': bloodPressureDiastolic,
    },
    'glucoseMgDl': glucoseMgDl,
    'temperatureC': temperatureC,
    'respiratoryRate': respiratoryRate,
    'sleepHours': sleepHours,
    'records': records,
    'sources': sources,
    'source': source,
  };
}

class SunyaHealthConnectService {
  final Health _health = Health();

  static const requestedTypes = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.WATER,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
    HealthDataType.NUTRITION,
  ];

  Future<void> configure() => _health.configure();

  Future<List<HealthDataType>> _availableTypes() async {
    await _health.configure();
    return requestedTypes.where(_health.isDataTypeAvailable).toList();
  }

  Future<bool> requestReadAccess() async {
    final types = await _availableTypes();
    if (types.isEmpty) return false;
    return _health.requestAuthorization(
      types,
      permissions: List.filled(types.length, HealthDataAccess.READ),
    );
  }

  Future<bool> get available async {
    try {
      await _health.configure();
      return await _health.isHealthConnectAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<SunyaHealthSnapshot> sync({int days = 30}) async {
    final types = await _availableTypes();
    if (types.isEmpty) return const SunyaHealthSnapshot();
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final points = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );
    final unique = _health.removeDuplicates(points);

    double sum(HealthDataType type) => unique
        .where((p) => p.type == type)
        .map((p) => p.value)
        .whereType<NumericHealthValue>()
        .fold(0, (a, b) => a + b.numericValue.toDouble());

    double? average(HealthDataType type) {
      final values = unique
          .where((p) => p.type == type)
          .map((p) => p.value)
          .whereType<NumericHealthValue>()
          .map((v) => v.numericValue.toDouble())
          .toList();
      if (values.isEmpty) return null;
      return values.reduce((a, b) => a + b) / values.length;
    }

    double? latest(HealthDataType type) {
      final values = unique.where((p) => p.type == type).toList();
      if (values.isEmpty) return null;
      values.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final value = values.first.value;
      return value is NumericHealthValue ? value.numericValue.toDouble() : null;
    }

    final sleep = unique
        .where((p) => p.type == HealthDataType.SLEEP_SESSION)
        .fold<double>(
          0,
          (a, p) => a + p.dateTo.difference(p.dateFrom).inMinutes / 60,
        );

    final sourceNames = unique
        .map((p) => p.sourceName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList();

    return SunyaHealthSnapshot(
      steps: sum(HealthDataType.STEPS).round(),
      activeCalories: sum(HealthDataType.ACTIVE_ENERGY_BURNED),
      totalCalories: sum(HealthDataType.TOTAL_CALORIES_BURNED),
      waterMl: sum(HealthDataType.WATER),
      weightKg: latest(HealthDataType.WEIGHT),
      heightCm: latest(HealthDataType.HEIGHT),
      bodyFatPercent: latest(HealthDataType.BODY_FAT_PERCENTAGE),
      bmi: latest(HealthDataType.BODY_MASS_INDEX),
      heartRate: average(HealthDataType.HEART_RATE),
      restingHeartRate: average(HealthDataType.RESTING_HEART_RATE),
      hrv: average(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      oxygen: average(HealthDataType.BLOOD_OXYGEN),
      bloodPressureSystolic: average(HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
      bloodPressureDiastolic: average(HealthDataType.BLOOD_PRESSURE_DIASTOLIC),
      glucoseMgDl: average(HealthDataType.BLOOD_GLUCOSE),
      temperatureC: average(HealthDataType.BODY_TEMPERATURE),
      respiratoryRate: average(HealthDataType.RESPIRATORY_RATE),
      sleepHours: sleep,
      records: unique.length,
      sources: sourceNames,
      source: _health.platformType.name,
    );
  }
}
