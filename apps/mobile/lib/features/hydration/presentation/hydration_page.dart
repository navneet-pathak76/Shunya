import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('Hydration', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Keep your daily hydration signal visible.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 22),
          SunyaGlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                SizedBox(
                  width: 190,
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: CircularProgressIndicator(
                          value: state.progress,
                          strokeWidth: 13,
                          backgroundColor: SunyaTheme.hydration.withOpacity(0.10),
                          valueColor: const AlwaysStoppedAnimation<Color>(SunyaTheme.hydration),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${state.consumedMl}', style: Theme.of(context).textTheme.displaySmall),
                          Text('of ${state.goalMl} ml', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('$percent% of today\'s target', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  state.consumedMl == 0 ? 'Log your first glass to start the day.' : 'Keep the trend steady throughout the day.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [250, 500, 750, 1000].map((ml) {
              return OutlinedButton.icon(
                onPressed: () => controller.add(ml),
                icon: const Icon(Icons.water_drop_outlined, size: 18),
                label: Text('$ml ml'),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset today'),
          ),
        ],
      ),
    );
  }
}
