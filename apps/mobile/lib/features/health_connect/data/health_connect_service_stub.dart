class SunyaHealthSnapshot {
  const SunyaHealthSnapshot({this.steps = 0, this.activeCalories = 0, this.totalCalories = 0, this.waterMl = 0, this.weightKg, this.heartRate, this.restingHeartRate, this.hrv, this.oxygen, this.sleepHours = 0, this.records = 0, this.source = 'Unavailable on web'});
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
  Future<void> configure() async {}
  Future<bool> requestReadAccess() async => false;
  Future<SunyaHealthSnapshot> sync({int days = 7}) async => const SunyaHealthSnapshot();
  Future<bool> get available async => false;
}
