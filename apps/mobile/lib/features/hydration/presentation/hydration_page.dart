import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hydration_controller.dart';

class HydrationPage extends ConsumerWidget {
  const HydrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hydrationProvider);
    final controller = ref.read(hydrationProvider.notifier);
    final percent = (state.progress * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Hydration')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hydration', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('$percent% of today\'s target', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${state.consumedMl} ml', style: Theme.of(context).textTheme.displaySmall),
                  Text('of ${state.goalMl} ml target'),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(value: state.progress, minHeight: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final ml in [250, 500, 750, 1000])
                OutlinedButton.icon(
                  onPressed: () => controller.add(ml),
                  icon: const Icon(Icons.water_drop_outlined),
                  label: Text('$ml ml'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: controller.reset, child: const Text('Reset today')),
        ],
      ),
    );
  }
}
