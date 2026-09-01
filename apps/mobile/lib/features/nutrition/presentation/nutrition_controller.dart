import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/storage_provider.dart';

class MealEntry {
  const MealEntry({required this.id, required this.name, required this.calories, required this.protein, required this.type});
  final String id;
  final String name;
  final int calories;
  final double protein;
  final String type;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'calories': calories, 'protein': protein, 'type': type};
  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(id: json['id'] as String, name: json['name'] as String, calories: (json['calories'] as num).toInt(), protein: (json['protein'] as num).toDouble(), type: json['type'] as String);
}

class NutritionState {
  const NutritionState({this.meals = const [], this.calorieGoal = 2200, this.proteinGoal = 140});
  final List<MealEntry> meals;
  final int calorieGoal;
  final double proteinGoal;
  int get calories => meals.fold(0, (sum, meal) => sum + meal.calories);
  double get protein => meals.fold(0, (sum, meal) => sum + meal.protein);
}

final nutritionProvider = StateNotifierProvider<NutritionController, NutritionState>((ref) => NutritionController(ref));

class NutritionController extends StateNotifier<NutritionState> {
  NutritionController(this.ref) : super(const NutritionState()) { _load(); }
  final Ref ref;
  static const _key = 'nutrition.today.meals';
  final _uuid = const Uuid();

  Future<void> _load() async {
    final storage = await ref.read(storageProvider.future);
    final meals = storage.readList(_key).map(MealEntry.fromJson).toList();
    state = NutritionState(meals: meals);
  }

  Future<void> addMeal({required String name, required String type, required int calories, required double protein}) async {
    final meal = MealEntry(id: _uuid.v4(), name: name.trim(), type: type, calories: calories, protein: protein);
    final meals = [...state.meals, meal];
    state = NutritionState(meals: meals);
    final storage = await ref.read(storageProvider.future);
    await storage.writeList(_key, meals.map((e) => e.toJson()).toList());
  }

  Future<void> removeMeal(String id) async {
    final meals = state.meals.where((e) => e.id != id).toList();
    state = NutritionState(meals: meals);
    final storage = await ref.read(storageProvider.future);
    await storage.writeList(_key, meals.map((e) => e.toJson()).toList());
  }
}
