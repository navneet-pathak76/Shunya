class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({
    this.steps = 0, this.activeCalories = 0, this.totalCalories = 0, this.basalCalories = 0,
    this.waterMl = 0, this.weightKg, this.heightCm, this.bodyFatPercent, this.bmi, this.waistCm,
    this.bodyWaterKg, this.heartRate, this.restingHeartRate, this.hrv, this.oxygen,
    this.bloodPressureSystolic, this.bloodPressureDiastolic, this.bloodGlucose,
    this.bodyTemperature, this.respiratoryRate, this.sleepHours = 0, this.distanceMeters = 0, this.nutritionCalories = 0, this.nutritionProteinGrams = 0,
    this.exerciseMinutes = 0, this.records = 0, this.sourceNames = const [], this.source = 'Unavailable on web',
  });
  final int steps;
  final double activeCalories, totalCalories, basalCalories, waterMl, sleepHours, distanceMeters, exerciseMinutes, nutritionCalories, nutritionProteinGrams;
  final double? weightKg, heightCm, bodyFatPercent, bmi, waistCm, bodyWaterKg, heartRate, restingHeartRate, hrv, oxygen, bloodPressureSystolic, bloodPressureDiastolic, bloodGlucose, bodyTemperature, respiratoryRate;
  double? get systolicBp => bloodPressureSystolic;
  double? get diastolicBp => bloodPressureDiastolic;
  double? get glucose => bloodGlucose;
  double? get temperatureC => bodyTemperature;
  final int records;
  final List<String> sourceNames;
  final String source;
  Map<String, dynamic> toContext() => {
    'steps': steps, 'activeCalories': activeCalories, 'totalCalories': totalCalories, 'basalCalories': basalCalories,
    'waterMl': waterMl, 'weightKg': weightKg, 'heightCm': heightCm, 'bodyFatPercent': bodyFatPercent, 'bmi': bmi,
    'waistCm': waistCm, 'bodyWaterKg': bodyWaterKg, 'heartRate': heartRate, 'restingHeartRate': restingHeartRate,
    'hrv': hrv, 'spo2': oxygen, 'bloodPressure': {'systolic': bloodPressureSystolic, 'diastolic': bloodPressureDiastolic},
    'bloodGlucose': bloodGlucose, 'bodyTemperature': bodyTemperature, 'respiratoryRate': respiratoryRate,
    'sleepHours': sleepHours, 'distanceMeters': distanceMeters, 'nutritionCalories': nutritionCalories, 'nutritionProteinGrams': nutritionProteinGrams, 'exerciseMinutes': exerciseMinutes,
    'records': records, 'sources': sourceNames, 'source': source,
  };
}
class SunyaHealthConnectService {
  Future<void> configure() async {}
  Future<bool> requestReadAccess() async => false;
  Future<SunyaHealthSnapshot> sync({int days = 30}) async => const SunyaHealthSnapshot();
  Future<bool> get available async => false;
  Future<bool> get historyAuthorized async => false;
  Future<bool> requestHistoryAccess() async => false;
}
