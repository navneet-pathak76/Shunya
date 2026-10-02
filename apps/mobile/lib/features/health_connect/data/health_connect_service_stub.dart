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
    this.source = 'Unavailable on web',
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
    'sleepHours': sleepHours,
  };
}
class SunyaHealthConnectService {
  Future<void> configure() async {}
  Future<bool> requestReadAccess() async => false;
  Future<SunyaHealthSnapshot> sync({int days = 7}) async => const SunyaHealthSnapshot();
  Future<bool> get available async => false;
}
