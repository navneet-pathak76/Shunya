class DailyState {
  const DailyState({
    required this.date,
    required this.weightKg,
    required this.waterMl,
    required this.waterGoalMl,
    required this.calories,
    required this.calorieGoal,
    required this.proteinGrams,
    required this.proteinGoal,
    required this.sleepHours,
    required this.workoutCompleted,
    required this.habitCompleted,
    required this.smokingCount,
    required this.alcoholUnits,
  });

  final DateTime date;
  final double? weightKg;
  final int waterMl;
  final int waterGoalMl;
  final int calories;
  final int calorieGoal;
  final double proteinGrams;
  final double proteinGoal;
  final double sleepHours;
  final bool workoutCompleted;
  final bool habitCompleted;
  final int smokingCount;
  final double alcoholUnits;

  double get waterProgress => _progress(waterMl, waterGoalMl);
  double get calorieProgress => _progress(calories, calorieGoal);
  double get proteinProgress => _progress(proteinGrams, proteinGoal);

  static double _progress(num value, num goal) => goal <= 0 ? 0 : (value / goal).clamp(0.0, 1.0).toDouble();
}
