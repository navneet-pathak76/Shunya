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
    this.source = 'Unavailable on web',
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
    'bloodPressure': {'systolic': bloodPressureSystolic, 'diastolic': bloodPressureDiastolic},
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
  Future<void> configure() async {}
  Future<bool> requestReadAccess() async => false;
  Future<SunyaHealthSnapshot> sync({int days = 30}) async => const SunyaHealthSnapshot();
  Future<bool> get available async => false;
}
