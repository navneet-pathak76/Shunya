import 'package:health/health.dart';

class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({
    this.steps = 0,
    this.activeCalories = 0,
    this.totalCalories = 0,
    this.basalCalories = 0,
    this.waterMl = 0,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.bmi,
    this.waistCm,
    this.bodyWaterKg,
    this.heartRate,
    this.restingHeartRate,
    this.hrv,
    this.oxygen,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bloodGlucose,
    this.bodyTemperature,
    this.respiratoryRate,
    this.sleepHours = 0,
    this.distanceMeters = 0,
    this.exerciseMinutes = 0,
    this.records = 0,
    this.sourceNames = const [],
    this.source = 'Health Connect',
  });

  final int steps;
  final double activeCalories;
  final double totalCalories;
  final double basalCalories;
  final double waterMl;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? bmi;
  final double? waistCm;
  final double? bodyWaterKg;
  final double? heartRate;
  final double? restingHeartRate;
  final double? hrv;
  final double? oxygen;
  final double? bloodPressureSystolic;
  final double? bloodPressureDiastolic;
  final double? bloodGlucose;
  final double? bodyTemperature;
  final double? respiratoryRate;
  final double sleepHours;
  final double distanceMeters;
  final double exerciseMinutes;
  final int records;
  final List<String> sourceNames;
  final String source;

  Map<String, dynamic> toContext() => {
    'steps': steps,
    'activeCalories': activeCalories,
    'totalCalories': totalCalories,
    'basalCalories': basalCalories,
    'waterMl': waterMl,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bodyFatPercent': bodyFatPercent,
    'bmi': bmi,
    'waistCm': waistCm,
    'bodyWaterKg': bodyWaterKg,
    'heartRate': heartRate,
    'restingHeartRate': restingHeartRate,
    'hrv': hrv,
    'spo2': oxygen,
    'bloodPressure': {'systolic': bloodPressureSystolic, 'diastolic': bloodPressureDiastolic},
    'bloodGlucose': bloodGlucose,
    'bodyTemperature': bodyTemperature,
    'respiratoryRate': respiratoryRate,
    'sleepHours': sleepHours,
    'distanceMeters': distanceMeters,
    'exerciseMinutes': exerciseMinutes,
    'records': records,
    'sources': sourceNames,
    'source': source,
  };
}

class SunyaHealthConnectService {
  final Health _health = Health();

  static const requestedTypes = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.WAIST_CIRCUMFERENCE,
    HealthDataType.BODY_WATER_MASS,
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

  Future<bool> get historyAuthorized async {
    try {
      await _health.configure();
      if (!await _health.isHealthDataHistoryAvailable()) return false;
      return await _health.isHealthDataHistoryAuthorized();
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestHistoryAccess() async {
    try {
      await _health.configure();
      if (!await _health.isHealthDataHistoryAvailable()) return false;
      return _health.requestHealthDataHistoryAuthorization();
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
      return values.isEmpty ? null : values.reduce((a, b) => a + b) / values.length;
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
        .fold<double>(0, (a, p) => a + p.dateTo.difference(p.dateFrom).inMinutes / 60);

    final sources = unique.map((p) => p.sourceName).where((x) => x.trim().isNotEmpty).toSet().toList();

    return SunyaHealthSnapshot(
      steps: sum(HealthDataType.STEPS).round(),
      activeCalories: sum(HealthDataType.ACTIVE_ENERGY_BURNED),
      totalCalories: sum(HealthDataType.TOTAL_CALORIES_BURNED),
      basalCalories: sum(HealthDataType.BASAL_ENERGY_BURNED),
      waterMl: sum(HealthDataType.WATER) * 1000,
      weightKg: latest(HealthDataType.WEIGHT),
      heightCm: latest(HealthDataType.HEIGHT) == null ? null : latest(HealthDataType.HEIGHT)! * 100,
      bodyFatPercent: latest(HealthDataType.BODY_FAT_PERCENTAGE),
      bmi: latest(HealthDataType.BODY_MASS_INDEX),
      waistCm: latest(HealthDataType.WAIST_CIRCUMFERENCE) == null ? null : latest(HealthDataType.WAIST_CIRCUMFERENCE)! * 100,
      bodyWaterKg: latest(HealthDataType.BODY_WATER_MASS),
      heartRate: average(HealthDataType.HEART_RATE),
      restingHeartRate: average(HealthDataType.RESTING_HEART_RATE),
      hrv: average(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      oxygen: average(HealthDataType.BLOOD_OXYGEN),
      bloodPressureSystolic: average(HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
      bloodPressureDiastolic: average(HealthDataType.BLOOD_PRESSURE_DIASTOLIC),
      bloodGlucose: average(HealthDataType.BLOOD_GLUCOSE),
      bodyTemperature: average(HealthDataType.BODY_TEMPERATURE),
      respiratoryRate: average(HealthDataType.RESPIRATORY_RATE),
      sleepHours: sleep,
      distanceMeters: sum(HealthDataType.DISTANCE_WALKING_RUNNING),
      exerciseMinutes: sum(HealthDataType.EXERCISE_TIME),
      records: unique.length,
      sourceNames: sources,
      source: _health.platformType.name,
    );
  }
}
