import 'dart:convert';

import '../../../database/local_record_repository.dart';
import '../presentation/nutrition_controller.dart';

class NutritionRepository {
  NutritionRepository(this._localRepository);

  final LocalRecordRepository _localRepository;
  static const domain = 'nutrition';

  String dayKey(DateTime date) => 'day:${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<List<MealEntry>> mealsForDay(DateTime date) async {
    final payload = await _localRepository.readPayload(domain, dayKey(date));
    if (payload == null) return const [];
    final raw = payload['meals'];
    if (raw is! List) return const [];
    return raw.map((item) => MealEntry.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<void> saveMeals(DateTime date, List<MealEntry> meals) {
    return _localRepository.upsert(
      domain: domain,
      key: dayKey(date),
      payload: {'meals': meals.map((meal) => meal.toJson()).toList()},
      recordDate: date,
    );
  }
}
