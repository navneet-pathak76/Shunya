class DailyLog {
  const DailyLog({
    required this.id,
    required this.date,
    this.waterMl = 0,
    this.sleepMinutes = 0,
    this.calories = 0,
    this.smokingCount = 0,
    this.alcoholUnits = 0,
    this.moodScore,
  });

  final String id;
  final DateTime date;
  final int waterMl;
  final int sleepMinutes;
  final int calories;
  final int smokingCount;
  final double alcoholUnits;
  final int? moodScore;
}
