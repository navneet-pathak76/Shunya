import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import 'nutrition_controller.dart';

class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);
    final calorieProgress = (state.calories / state.calorieGoal).clamp(0.0, 1.0);
    final proteinProgress = (state.protein / state.proteinGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMeal(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Meal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text('Nutrition', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Build a simple daily record of what you eat.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          SunyaGlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressLine(label: 'Calories', current: state.calories.toString(), target: '${state.calorieGoal} kcal', value: calorieProgress, color: SunyaTheme.blueBright),
                const SizedBox(height: 20),
                _ProgressLine(label: 'Protein', current: state.protein.toStringAsFixed(0), target: '${state.proteinGoal.toStringAsFixed(0)} g', value: proteinProgress, color: SunyaTheme.nutrition),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Text('Today\'s meals', style: Theme.of(context).textTheme.titleLarge)),
              Text('${state.meals.length}', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          if (state.meals.isEmpty)
            SunyaGlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.restaurant_menu_rounded, size: 34, color: SunyaTheme.nutrition),
                  const SizedBox(height: 12),
                  Text('Nothing logged yet', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Add your first meal to start the daily nutrition record.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          else
            ...state.meals.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SunyaGlassCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: SunyaTheme.blueSoft,
                      child: Icon(Icons.restaurant_outlined, color: SunyaTheme.blueBright),
                    ),
                    title: Text(meal.name),
                    subtitle: Text('${meal.type} · ${meal.calories} kcal · ${meal.protein.toStringAsFixed(1)} g protein'),
                    trailing: IconButton(
                      tooltip: 'Delete meal',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => ref.read(nutritionProvider.notifier).removeMeal(meal.id),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _addMeal(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final calories = TextEditingController();
    final protein = TextEditingController();
    String type = 'Breakfast';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add meal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                DropdownButtonFormField<String>(
                  value: type,
                  items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => type = v ?? 'Breakfast'),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(controller: calories, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories (kcal)')),
                TextField(controller: protein, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Protein (g)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final mealName = name.text.trim();
                final kcal = int.tryParse(calories.text);
                final grams = double.tryParse(protein.text);
                if (mealName.isEmpty || kcal == null || grams == null) return;
                await ref.read(nutritionProvider.notifier).addMeal(name: mealName, type: type, calories: kcal, protein: grams);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    calories.dispose();
    protein.dispose();
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.label, required this.current, required this.target, required this.value, required this.color});
  final String label;
  final String current;
  final String target;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              Text('$current / $target', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      );
}
