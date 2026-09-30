class HealthProfileInput {
  const HealthProfileInput({this.weightKg, this.heightCm, this.ageYears, this.sex, this.activityMultiplier = 1.45, this.goal = 'maintain', this.dailySteps = 0, this.sleepHours, this.hydrationMl = 0, this.proteinConsumed = 0});
  final double? weightKg;
  final double? heightCm;
  final int? ageYears;
  final String? sex;
  final double activityMultiplier;
  final String goal;
  final int dailySteps;
  final double? sleepHours;
  final int hydrationMl;
  final double proteinConsumed;
}

class AdaptivePlan {
  const AdaptivePlan({required this.bmi, required this.bmr, required this.calorieTarget, required this.proteinTarget, required this.waterTargetMl, required this.recoveryScore, required this.trainingMode, required this.priority, required this.actions});
  final double? bmi;
  final int? bmr;
  final int calorieTarget;
  final int proteinTarget;
  final int waterTargetMl;
  final int recoveryScore;
  final String trainingMode;
  final String priority;
  final List<String> actions;
}

class AdaptiveHealthEngine {
  static AdaptivePlan build(HealthProfileInput input) {
    final weight = input.weightKg;
    final height = input.heightCm;
    final bmi = weight != null && height != null && height > 0 ? weight / ((height / 100) * (height / 100)) : null;
    int? bmr;
    if (weight != null && height != null && input.ageYears != null) {
      final offset = input.sex?.toLowerCase() == 'female' ? -161 : 5;
      bmr = (10 * weight + 6.25 * height - 5 * input.ageYears! + offset).round();
    }
    final maintenance = bmr == null ? 2200 : (bmr * input.activityMultiplier).round();
    final calorieTarget = switch (input.goal.toLowerCase()) {
      'lose' || 'cut' => (maintenance - 350).clamp(1400, 5000),
      'gain' || 'bulk' => maintenance + 250,
      _ => maintenance,
    };
    final proteinTarget = weight == null ? 120 : (weight * 1.6).round();
    final waterTarget = weight == null ? 2500 : (weight * 35).round();
    var recovery = 75;
    if (input.sleepHours != null) {
      if (input.sleepHours! < 6) recovery -= 20;
      else if (input.sleepHours! < 7) recovery -= 10;
      else if (input.sleepHours! >= 8) recovery += 5;
    }
    if (input.hydrationMl < waterTarget * 0.5) recovery -= 8;
    if (input.proteinConsumed > 0 && input.proteinConsumed < proteinTarget * 0.5) recovery -= 5;
    recovery = recovery.clamp(0, 100);
    final trainingMode = recovery < 55 ? 'Recovery / light movement' : recovery < 70 ? 'Moderate training' : 'Normal training';
    final priority = recovery < 60 ? 'Recovery' : input.hydrationMl < waterTarget * 0.6 ? 'Hydration' : input.proteinConsumed < proteinTarget * 0.6 ? 'Nutrition' : 'Training';
    final actions = <String>[];
    if (input.hydrationMl < waterTarget) actions.add('Drink more water today.');
    if (input.proteinConsumed < proteinTarget) actions.add('Increase protein intake toward your daily target.');
    if (input.sleepHours != null && input.sleepHours! < 7) actions.add('Protect tonight\'s sleep window.');
    if (input.dailySteps < 7000) actions.add('Add a short walk to increase daily movement.');
    if (actions.isEmpty) actions.add('Keep your current routine and log consistently.');
    return AdaptivePlan(bmi: bmi, bmr: bmr, calorieTarget: calorieTarget, proteinTarget: proteinTarget, waterTargetMl: waterTarget, recoveryScore: recovery, trainingMode: trainingMode, priority: priority, actions: actions);
  }
}
