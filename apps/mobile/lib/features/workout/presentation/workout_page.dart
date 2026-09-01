import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Workout',
        description: 'Training sessions, exercises, volume and progression.',
        metrics: const [
          SunyaModuleMetric(label: 'Sessions', value: '0', unit: 'this week', icon: Icons.calendar_today_outlined),
          SunyaModuleMetric(label: 'Volume', value: '0', unit: 'kg', icon: Icons.fitness_center_outlined),
          SunyaModuleMetric(label: 'Exercises', value: '0', unit: '', icon: Icons.list_alt_outlined),
          SunyaModuleMetric(label: 'Streak', value: '0', unit: 'days', icon: Icons.local_fire_department_outlined),
        ],
      );
}
