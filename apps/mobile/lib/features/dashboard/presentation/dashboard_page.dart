import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_metric_card.dart';
import '../../hydration/presentation/hydration_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../workout/presentation/workout_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydration = ref.watch(hydrationProvider);
    final nutrition = ref.watch(nutritionProvider);
    final workouts = ref.watch(workoutControllerProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    final weeklyWorkouts = workouts.where((w) => DateTime.now().difference(w.startedAt).inDays < 7).length;

    return Scaffold(
      appBar: AppBar(title: const Text('SUNYA'), actions: [IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline))]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Your body, habits, data and goals in one place.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: SunyaMetricCard(label: 'Water', value: '${hydration.consumedMl}', unit: 'ml', icon: Icons.water_drop_outlined)),
            const SizedBox(width: 12),
            Expanded(child: SunyaMetricCard(label: 'Calories', value: '${nutrition.calories}', unit: 'kcal', icon: Icons.local_fire_department_outlined)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: SunyaMetricCard(label: 'Protein', value: nutrition.protein.toStringAsFixed(0), unit: 'g', icon: Icons.egg_alt_outlined)),
            const SizedBox(width: 12),
            Expanded(child: SunyaMetricCard(label: 'Workouts', value: '$weeklyWorkouts', unit: '7 days', icon: Icons.fitness_center_outlined)),
          ]),
          const SizedBox(height: 28),
          Text('Today', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(child: ListTile(
            leading: const Icon(Icons.water_drop_outlined, color: SunyaTheme.hydration),
            title: Text('${hydration.consumedMl} / ${hydration.goalMl} ml water'),
            subtitle: Padding(padding: const EdgeInsets.only(top: 8), child: LinearProgressIndicator(value: hydration.progress)),
            trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/hydration'),
          )),
          const SizedBox(height: 10),
          Card(child: ListTile(
            leading: const Icon(Icons.local_fire_department_outlined, color: SunyaTheme.orange),
            title: Text('${nutrition.calories} / ${nutrition.calorieGoal} kcal'),
            subtitle: Text('${nutrition.protein.toStringAsFixed(0)} / ${nutrition.proteinGoal.toStringAsFixed(0)} g protein'),
            trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/nutrition'),
          )),
          const SizedBox(height: 28),
          Text('Modules', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35,
            children: const [
              _Module('Body', '/body', Icons.accessibility_new_outlined), _Module('Nutrition', '/nutrition', Icons.restaurant_outlined),
              _Module('Hydration', '/hydration', Icons.water_drop_outlined), _Module('Workout', '/workout', Icons.fitness_center_outlined),
              _Module('Sleep', '/sleep', Icons.bedtime_outlined), _Module('Habits', '/habits', Icons.repeat_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Card(child: ListTile(leading: const Icon(Icons.auto_awesome_outlined), title: const Text('SUNYA AI'), subtitle: const Text('Personal insights from your tracked data.'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/ai'))),
        ],
      ),
    );
  }
}

class _Module extends StatelessWidget {
  const _Module(this.name, this.route, this.icon);
  final String name; final String route; final IconData icon;
  @override Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, child: InkWell(onTap: () => context.push(route), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon), const Spacer(), Text(name, style: Theme.of(context).textTheme.titleMedium)]))));
}
