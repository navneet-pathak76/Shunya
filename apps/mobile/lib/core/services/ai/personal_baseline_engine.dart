class HealthTrend {
  const HealthTrend({required this.metric, required this.direction, required this.change, required this.interpretation});
  final String metric;
  final String direction;
  final double change;
  final String interpretation;

  Map<String, dynamic> toJson() => {
    'metric': metric,
    'direction': direction,
    'change': change,
    'interpretation': interpretation,
  };
}

class PersonalBaseline {
  const PersonalBaseline({
    required this.windowDays,
    required this.dataCoverage,
    required this.recoveryIndex,
    required this.trends,
    required this.flags,
  });

  final int windowDays;
  final double dataCoverage;
  final double recoveryIndex;
  final List<HealthTrend> trends;
  final List<String> flags;

  Map<String, dynamic> toJson() => {
    'windowDays': windowDays,
    'dataCoverage': dataCoverage,
    'recoveryIndex': recoveryIndex,
    'trends': trends.map((e) => e.toJson()).toList(),
    'flags': flags,
  };
}

class PersonalBaselineEngine {
  static PersonalBaseline build({
    required double? currentWeight,
    required double? previousWeight,
    required double? bodyFat,
    required double? previousBodyFat,
    required double? sleepHours,
    required double? previousSleepHours,
    required int steps,
    required double waterMl,
    required double waterTargetMl,
    required double? restingHeartRate,
    required double? previousRestingHeartRate,
    int windowDays = 30,
  }) {
    final trends = <HealthTrend>[];
    if (currentWeight != null && previousWeight != null) {
      final delta = currentWeight - previousWeight;
      trends.add(HealthTrend(
        metric: 'weight',
        direction: delta.abs() < .25 ? 'stable' : delta < 0 ? 'down' : 'up',
        change: delta,
        interpretation: 'Change versus the previous available body measurement.',
      ));
    }
    if (bodyFat != null && previousBodyFat != null) {
      final delta = bodyFat - previousBodyFat;
      trends.add(HealthTrend(
        metric: 'bodyFat',
        direction: delta.abs() < .2 ? 'stable' : delta < 0 ? 'down' : 'up',
        change: delta,
        interpretation: 'Change versus the previous available body-fat measurement.',
      ));
    }
    if (sleepHours != null && previousSleepHours != null) {
      final delta = sleepHours - previousSleepHours;
      trends.add(HealthTrend(
        metric: 'sleep',
        direction: delta.abs() < .15 ? 'stable' : delta < 0 ? 'down' : 'up',
        change: delta,
        interpretation: 'Change versus the previous available sleep entry.',
      ));
    }
    if (restingHeartRate != null && previousRestingHeartRate != null) {
      final delta = restingHeartRate - previousRestingHeartRate;
      trends.add(HealthTrend(
        metric: 'restingHeartRate',
        direction: delta.abs() < 2 ? 'stable' : delta < 0 ? 'down' : 'up',
        change: delta,
        interpretation: 'Change versus the previous available resting-heart-rate estimate.',
      ));
    }

    final coverage = [
      currentWeight,
      bodyFat,
      sleepHours,
      restingHeartRate,
    ].whereType<double>().length / 4.0;

    var recovery = 70.0;
    if (sleepHours != null) {
      if (sleepHours < 6) recovery -= 20;
      else if (sleepHours < 7) recovery -= 10;
      else if (sleepHours >= 8) recovery += 5;
    }
    if (waterTargetMl > 0 && waterMl < waterTargetMl * .6) recovery -= 10;
    if (steps < 5000) recovery -= 5;
    recovery = recovery.clamp(0, 100).toDouble();

    final flags = <String>[];
    if (coverage < .5) flags.add('Collect more baseline data before making strong trend claims.');
    if (sleepHours != null && sleepHours < 7) flags.add('Sleep is below the 7-hour target used by the baseline engine.');
    if (waterTargetMl > 0 && waterMl < waterTargetMl * .6) flags.add('Hydration is materially below the current target.');
    if (steps < 5000) flags.add('Daily movement is currently low relative to the baseline threshold.');

    return PersonalBaseline(
      windowDays: windowDays,
      dataCoverage: coverage,
      recoveryIndex: recovery,
      trends: trends,
      flags: flags,
    );
  }
}
