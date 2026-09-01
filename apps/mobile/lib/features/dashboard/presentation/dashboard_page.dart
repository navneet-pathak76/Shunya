import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/sunya_metric_card.dart';
import '../../hydration/presentation/hydration_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const modules = <_DashboardModule>[
    _DashboardModule('Body', '/body', Icons.accessibility_new_outlined),
    _DashboardModule('Nutrition', '/nutrition', Icons.restaurant_outlined),
    _DashboardModule('Hydration', '/hydration', Icons.water_drop_outlined),
    _DashboardModule('Workout', '/workout', Icons.fitness_center_outlined),
    _DashboardModule('Sleep', '/sleep', Icons.bedtime_outlined),
    _DashboardModule('Habits', '/habits', Icons.repeat_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydration = ref.watch(hydrationProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA'),
        actions: [
          IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline), tooltip: 'Profile'),
        ],
      ),
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
            const Expanded(child: SunyaMetricCard(label: 'Calories', value: '0', unit: 'kcal', icon: Icons.local_fire_department_outlined)),
          ]),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: SunyaMetricCard(label: 'Sleep', value: '—', unit: 'h', icon: Icons.bedtime_outlined)),
            SizedBox(width: 12),
            Expanded(child: SunyaMetricCard(label: 'Workouts', value: '0', unit: 'week', icon: Icons.fitness_center_outlined)),
          ]),
          const SizedBox(height: 28),
          Text('Today', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop_outlined),
              title: Text('${hydration.consumedMl} / ${hydration.goalMl} ml water'),
              subtitle: LinearProgressIndicator(value: hydration.progress),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/hydration'),
            ),
          ),
          const SizedBox(height: 28),
          Text('Modules', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.35),
            itemBuilder: (context, index) {
              final module = modules[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push(module.route),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Icon(module.icon),
                      const Spacer(),
                      Text(module.name, style: Theme.of(context).textTheme.titleMedium),
                    ]),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('SUNYA AI'),
              subtitle: const Text('Personal insights will be generated from your data.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/ai'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule(this.name, this.route, this.icon);
  final String name;
  final String route;
  final IconData icon;
}
