import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import 'workout_controller.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutControllerProvider);
    final volume = sessions.fold<double>(0, (sum, session) => sum + session.volumeKg);
    final exercises = sessions.fold<int>(0, (sum, session) => sum + session.exerciseCount);
    final open = sessions.where((session) => session.endedAt == null).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Set'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text('Training', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Sessions, volume and progression — stored locally on this device.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _Stat(label: 'Sessions', value: '${sessions.length}', icon: Icons.calendar_today_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _Stat(label: 'Volume', value: '${volume.toStringAsFixed(0)} kg', icon: Icons.fitness_center_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _Stat(label: 'Exercises', value: '$exercises', icon: Icons.list_alt_outlined)),
            ],
          ),
          const SizedBox(height: 20),
          if (open)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SunyaPrimaryButton(
                label: 'Finish current session',
                onPressed: () => ref.read(workoutControllerProvider.notifier).finishCurrentSession(),
                icon: Icons.stop_circle_outlined,
              ),
            ),
          if (sessions.isEmpty)
            SunyaGlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center_rounded, size: 36, color: SunyaTheme.blueBright),
                  const SizedBox(height: 12),
                  Text('No training logged', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Add your first set. SUNYA will build your training history from there.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          else
            ...sessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SunyaGlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: SunyaTheme.blueSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.fitness_center_outlined, color: SunyaTheme.blueBright),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.endedAt == null ? 'Active session' : 'Completed session', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 3),
                            Text('${session.sets.length} sets · ${session.volumeKg.toStringAsFixed(0)} kg volume', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => ref.read(workoutControllerProvider.notifier).deleteSession(session.id),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> _addSet(BuildContext context, WidgetRef ref) async {
    final exercise = TextEditingController();
    final reps = TextEditingController();
    final weight = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: exercise, decoration: const InputDecoration(labelText: 'Exercise')),
            TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Repetitions')),
            TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = exercise.text.trim();
              final r = int.tryParse(reps.text);
              final w = double.tryParse(weight.text);
              if (name.isEmpty || r == null || r <= 0 || w == null || w < 0) return;
              await ref.read(workoutControllerProvider.notifier).addSet(exerciseName: name, repetitions: r, weightKg: w);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    exercise.dispose();
    reps.dispose();
    weight.dispose();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SunyaGlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: SunyaTheme.blueBright, size: 20),
            const SizedBox(height: 14),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 3),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      );
}
