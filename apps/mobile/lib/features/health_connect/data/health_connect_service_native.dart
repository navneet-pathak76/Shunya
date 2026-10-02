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
    this.bloodGlucose,
    this.bodyTemperature,
    this.respiratoryRate,
    this.bodyWaterKg,
    this.basalCalories = 0,
    this.waistCm,
    this.distanceMeters = 0,
    this.exerciseMinutes = 0,
    this.sleepHours = 0,
    this.records = 0,
    this.source = 'Health Connect',
    this.sourceNames = const [],
    this.metrics = const {},
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
  final double? bloodGlucose;
  final double? bodyTemperature;
  final double? respiratoryRate;
  final double? bodyWaterKg;
  final double basalCalories;
  final double? waistCm;
  final double distanceMeters;
  final double exerciseMinutes;
  final double sleepHours;
  final int records;
  final String source;
  final List<String> sourceNames;
  final Map<String, double> metrics;

  Map<String, dynamic> toAiContext() => {
        'source': source,
        'records': records,
        'sources': sourceNames,
        'metrics': metrics,
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
        'bloodPressureSystolic': bloodPressureSystolic,
        'bloodPressureDiastolic': bloodPressureDiastolic,
        'bloodGlucose': bloodGlucose,
        'bodyTemperature': bodyTemperature,
        'respiratoryRate': respiratoryRate,
        'bodyWaterKg': bodyWaterKg,
        'basalCalories': basalCalories,
        'waistCm': waistCm,
        'distanceMeters': distanceMeters,
        'exerciseMinutes': exerciseMinutes,
        'sleepHours': sleepHours,
      };
}

class SunyaHealthConnectService {
  final Health _health = Health();

  static const candidateTypes = <HealthDataType>[
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
    HealthDataType.BODY_WATER_MASS,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.WAIST_CIRCUMFERENCE,
    HealthDataType.WATER,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
    HealthDataType.NUTRITION,
  ];

  Future<void> configure() => _health.configure();

  List<HealthDataType> get availableTypes {
    return candidateTypes.where((type) {
      try {
        return _health.isDataTypeAvailable(type);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Future<bool> requestReadAccess() async {
    await _health.configure();
    final types = availableTypes;
    if (types.isEmpty) return false;
    return _health.requestAuthorization(
      types,
      permissions: List.filled(types.length, HealthDataAccess.READ),
    );
  }

  Future<bool> get historyAvailable async {
    try {
      await _health.configure();
      return await _health.isHealthDataHistoryAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestHistoryAccess() async {
    try {
      await _health.configure();
      if (!await _health.isHealthDataHistoryAvailable()) return false;
      return await _health.requestHealthDataHistoryAuthorization();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get historyAuthorized async {
    try {
      await _health.configure();
      return await _health.isHealthDataHistoryAuthorized();
    } catch (_) {
      return false;
    }
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
    await _health.configure();
    final types = availableTypes;
    if (types.isEmpty) {
      return const SunyaHealthSnapshot(source: 'Health Connect unavailable');
    }

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final points = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    double sum(HealthDataType type) {
      return points
          .where((p) => p.type == type)
          .map((p) => p.value)
          .whereType<NumericHealthValue>()
          .fold(0, (a, b) => a + b.numericValue.toDouble());
    }

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

    double? latestNumeric(HealthDataType type) {
      final values = points.where((p) => p.type == type).toList();
      if (values.isEmpty) return null;
      values.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final value = values.first.value;
      return value is NumericHealthValue ? value.numericValue.toDouble() : null;
    }

    final sleep = points
        .where((p) => p.type == HealthDataType.SLEEP_SESSION)
        .fold<double>(
          0,
          (a, p) => a + p.dateTo.difference(p.dateFrom).inMinutes / 60,
        );

    final metrics = <String, double>{};
    for (final type in types) {
      final value = sum(type);
      if (value != 0) metrics[type.name] = value;
    }

    final sourceNames = points.map((p) => p.sourceName).where((s) => s.trim().isNotEmpty).toSet().toList();

    return SunyaHealthSnapshot(
      steps: sum(HealthDataType.STEPS).round(),
      activeCalories: sum(HealthDataType.ACTIVE_ENERGY_BURNED),
      totalCalories: sum(HealthDataType.TOTAL_CALORIES_BURNED),
      waterMl: sum(HealthDataType.WATER),
      weightKg: latestNumeric(HealthDataType.WEIGHT),
      heightCm: latestNumeric(HealthDataType.HEIGHT) == null ? null : latestNumeric(HealthDataType.HEIGHT)! * 100,
      bodyFatPercent: latestNumeric(HealthDataType.BODY_FAT_PERCENTAGE),
      bmi: latestNumeric(HealthDataType.BODY_MASS_INDEX),
      heartRate: average(HealthDataType.HEART_RATE),
      restingHeartRate: average(HealthDataType.RESTING_HEART_RATE),
      hrv: average(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      oxygen: average(HealthDataType.BLOOD_OXYGEN),
      bloodPressureSystolic: average(HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
      bloodPressureDiastolic: average(HealthDataType.BLOOD_PRESSURE_DIASTOLIC),
      bloodGlucose: average(HealthDataType.BLOOD_GLUCOSE),
      bodyTemperature: average(HealthDataType.BODY_TEMPERATURE),
      respiratoryRate: average(HealthDataType.RESPIRATORY_RATE),
      bodyWaterKg: latestNumeric(HealthDataType.BODY_WATER_MASS),
      basalCalories: sum(HealthDataType.BASAL_ENERGY_BURNED),
      waistCm: latestNumeric(HealthDataType.WAIST_CIRCUMFERENCE),
      distanceMeters: sum(HealthDataType.DISTANCE_WALKING_RUNNING),
      exerciseMinutes: sum(HealthDataType.EXERCISE_TIME) / 60,
      sleepHours: sleep,
      records: points.length,
      source: _health.platformType.name,
      sourceNames: sourceNames,
      metrics: metrics,
    );
  }
}
