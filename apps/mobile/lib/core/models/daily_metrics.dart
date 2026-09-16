class DailyMetrics {
  const DailyMetrics({
    required this.hydrationMl,
    required this.hydrationGoalMl,
    required this.calories,
    required this.calorieGoal,
    required this.workouts,
    required this.sleepHours,
    required this.habitsCompleted,
    required this.habitsTotal,
  });

  final int hydrationMl;
  final int hydrationGoalMl;
  final int calories;
  final int calorieGoal;
  final int workouts;
  final double? sleepHours;
  final int habitsCompleted;
  final int habitsTotal;

  double get hydrationProgress => hydrationGoalMl == 0 ? 0 : (hydrationMl / hydrationGoalMl).clamp(0, 1).toDouble();
  double get calorieProgress => calorieGoal == 0 ? 0 : (calories / calorieGoal).clamp(0, 1).toDouble();
  double get habitProgress => habitsTotal == 0 ? 0 : (habitsCompleted / habitsTotal).clamp(0, 1).toDouble();
}
