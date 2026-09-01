import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nutrition_controller.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _addMeal(context, ref), icon: const Icon(Icons.add), label: const Text('Meal')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Nutrition', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('${state.calories} / ${state.calorieGoal} kcal · ${state.protein.toStringAsFixed(0)} / ${state.proteinGoal.toStringAsFixed(0)} g protein'),
        const SizedBox(height: 20),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Calories', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (state.calories / state.calorieGoal).clamp(0.0, 1.0)),
          const SizedBox(height: 16),
          Text('Protein', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (state.protein / state.proteinGoal).clamp(0.0, 1.0)),
        ]))),
        const SizedBox(height: 20),
        if (state.meals.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No meals logged today. Add breakfast, lunch, dinner or a snack.')))
        else
          ...state.meals.map((meal) => Card(child: ListTile(
                leading: const Icon(Icons.restaurant_outlined),
                title: Text(meal.name),
                subtitle: Text('${meal.type} · ${meal.calories} kcal · ${meal.protein.toStringAsFixed(1)} g protein'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(nutritionProvider.notifier).removeMeal(meal.id)),
              ))),
      ]),
    );
  }

  static Future<void> _addMeal(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final calories = TextEditingController();
    final protein = TextEditingController();
    String type = 'Breakfast';
    await showDialog<void>(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
          title: const Text('Add meal'),
          content: SingleChildScrollView(child: Column(children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            DropdownButtonFormField<String>(value: type, items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => type = v ?? 'Breakfast'), decoration: const InputDecoration(labelText: 'Type')),
            TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)')),
            TextField(controller: protein, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Protein (g)')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () async {
              final mealName = name.text.trim();
              final kcal = int.tryParse(calories.text);
              final grams = double.tryParse(protein.text);
              if (mealName.isEmpty || kcal == null || grams == null) return;
              await ref.read(nutritionProvider.notifier).addMeal(name: mealName, type: type, calories: kcal, protein: grams);
              if (context.mounted) Navigator.pop(context);
            }, child: const Text('Save')),
          ],
        )));
    name.dispose(); calories.dispose(); protein.dispose();
  }
}
