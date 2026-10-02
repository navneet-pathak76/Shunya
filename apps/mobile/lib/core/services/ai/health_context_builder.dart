import '../../../features/body/presentation/body_controller.dart';
import '../../../features/health_connect/data/health_connect_service.dart';
import '../../../features/hydration/presentation/hydration_controller.dart';
import '../../../features/nutrition/presentation/nutrition_controller.dart';
import '../../../features/sleep/presentation/sleep_controller.dart';

class SunyaHealthContextBuilder {
  static Map<String, dynamic> build({
    required BodyState body,
    required HydrationState hydration,
    required NutritionState nutrition,
    required SleepState sleep,
    required SunyaHealthSnapshot health,
    required String name,
    required String goal,
  }) {
    final recentBody = body.measurements.reversed.take(20).map((m) => {
          'date': m.date.toIso8601String(),
          'weightKg': m.weightKg,
          'heightCm': m.heightCm,
          'bodyFatPercent': m.bodyFatPercent,
          'bmi': m.bmi,
          'notes': m.notes,
        }).toList();

    final regionHistory = body.regionMeasurements.reversed.take(30).map((m) => {
          'date': m.recordedAt.toIso8601String(),
          'region': m.region.name,
          'cm': m.centimetres,
          'note': m.note,
        }).toList();

    final meals = nutrition.meals.map((m) => m.toJson()).toList();
    final sleepHistory = sleep.entries.take(14).map((e) => {
          'startedAt': e.startedAt.toIso8601String(),
          'endedAt': e.endedAt.toIso8601String(),
          'hours': e.hours,
          'quality': e.quality,
        }).toList();

    return {
      'user': {
        'name': name,
        'goal': goal,
        'age': body.profile?.dateOfBirth == null
            ? null
            : DateTime.now().difference(body.profile!.dateOfBirth!).inDays ~/ 365,
        'biologicalSex': body.profile?.biologicalSex,
      },
      'currentBody': {
        'weightKg': body.weightKg,
        'heightCm': body.heightCm,
        'bodyFatPercent': body.bodyFatPercent,
        'bmi': body.bmi,
      },
      'bodyHistory': recentBody,
      'bodyRegionHistory': regionHistory,
      'todayNutrition': {
        'calorieGoal': nutrition.calorieGoal,
        'proteinGoal': nutrition.proteinGoal,
        'caloriesLogged': nutrition.calories,
        'proteinLogged': nutrition.protein,
        'meals': meals,
      },
      'todayHydration': {
        'consumedMl': hydration.consumedMl,
        'goalMl': hydration.goalMl,
      },
      'sleepHistory': sleepHistory,
      'healthConnect': health.toContext(),
    };
  }
}
