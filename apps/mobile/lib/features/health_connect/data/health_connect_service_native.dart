import 'package:health/health.dart';

class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({
    this.steps = 0,
    this.distanceMeters = 0,
    this.activeCalories = 0,
    this.totalCalories = 0,
    this.basalCalories = 0,
    this.waterMl = 0,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.bmi,
    this.heartRate,
    this.restingHeartRate,
    this.hrv,
    this.oxygen,
    this.systolicBp,
    this.diastolicBp,
    this.glucose,
    this.temperatureC,
    this.respiratoryRate,
    this.sleepHours = 0,
    this.exerciseMinutes = 0,
    this.records = 0,
    this.source = 'Health platform',
  });

  final int steps;
  final double distanceMeters;
  final double activeCalories;
  final double totalCalories;
  final double basalCalories;
  final double waterMl;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? bmi;
  final double? heartRate;
  final double? restingHeartRate;
  final double? hrv;
  final double? oxygen;
  final double? systolicBp;
  final double? diastolicBp;
  final double? glucose;
  final double? temperatureC;
  final double? respiratoryRate;
  final double sleepHours;
  final double exerciseMinutes;
  final int records;
  final String source;

  Map<String, dynamic> toContext() => {
    'steps': steps,
    'distanceMeters': distanceMeters,
    'activeCalories': activeCalories,
    'totalCalories': totalCalories,
    'basalCalories': basalCalories,
    'waterMl': waterMl,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bodyFatPercent': bodyFatPercent,
    'bmi': bmi,
    'heartRate': heartRate,
    'restingHeartRate': restingHeartRate,
    'hrv': hrv,
    'spo2': oxygen,
    'bloodPressure': {'systolic': systolicBp, 'diastolic': diastolicBp},
    'bloodGlucose': glucose,
    'bodyTemperatureC': temperatureC,
    'respiratoryRate': respiratoryRate,
    'sleepHours': sleepHours,
    'exerciseMinutes': exerciseMinutes,
    'records': records,
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

  List<HealthDataType> get availableTypes =>
      requestedTypes.where(_health.isDataTypeAvailable).toList();

  Future<bool> requestReadAccess() async {
    await _health.configure();
    final types = availableTypes;
    if (types.isEmpty) return false;
    var granted = false;
    for (final type in types) {
      try {
        final ok = await _health.requestAuthorization(
          [type],
          permissions: const [HealthDataAccess.READ],
        );
        granted = granted || ok;
      } catch (_) {
        // A restricted metric must not block the remaining supported metrics.
      }
    }
    return granted;
  }

  Future<bool> get available async {
    try {
      await _health.configure();
      if (!await _health.isHealthConnectAvailable()) return false;
      return availableTypes.contains(HealthDataType.STEPS);
    } catch (_) {
      return false;
    }
  }

  Future<SunyaHealthSnapshot> sync({int days = 7}) async {
    await _health.configure();
    final types = availableTypes;
    if (types.isEmpty) {
      return const SunyaHealthSnapshot(source: 'Health Connect unavailable');
    }

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    var points = await _health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );
    points = _health.removeDuplicates(points);

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
      return values.isEmpty
          ? null
          : values.reduce((a, b) => a + b) / values.length;
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

    final exerciseMinutes = points
        .where((p) => p.type == HealthDataType.EXERCISE_TIME)
        .fold<double>(
          0,
          (a, p) => a + (p.value is NumericHealthValue
              ? (p.value as NumericHealthValue).numericValue.toDouble()
              : 0),
        );

    return SunyaHealthSnapshot(
      steps: sum(HealthDataType.STEPS).round(),
      distanceMeters: sum(HealthDataType.DISTANCE_WALKING_RUNNING),
      activeCalories: sum(HealthDataType.ACTIVE_ENERGY_BURNED),
      totalCalories: sum(HealthDataType.TOTAL_CALORIES_BURNED),
      basalCalories: sum(HealthDataType.BASAL_ENERGY_BURNED),
      waterMl: sum(HealthDataType.WATER),
      weightKg: latestNumeric(HealthDataType.WEIGHT),
      heightCm: latestNumeric(HealthDataType.HEIGHT),
      bodyFatPercent: latestNumeric(HealthDataType.BODY_FAT_PERCENTAGE),
      bmi: latestNumeric(HealthDataType.BODY_MASS_INDEX),
      heartRate: average(HealthDataType.HEART_RATE),
      restingHeartRate: average(HealthDataType.RESTING_HEART_RATE),
      hrv: average(HealthDataType.HEART_RATE_VARIABILITY_RMSSD),
      oxygen: average(HealthDataType.BLOOD_OXYGEN),
      systolicBp: average(HealthDataType.BLOOD_PRESSURE_SYSTOLIC),
      diastolicBp: average(HealthDataType.BLOOD_PRESSURE_DIASTOLIC),
      glucose: average(HealthDataType.BLOOD_GLUCOSE),
      temperatureC: average(HealthDataType.BODY_TEMPERATURE),
      respiratoryRate: average(HealthDataType.RESPIRATORY_RATE),
      sleepHours: sleep,
      exerciseMinutes: exerciseMinutes,
      records: points.length,
      source: _health.platformType.name,
    );
  }
}
