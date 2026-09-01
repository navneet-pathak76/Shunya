import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Habits',
        description: 'Daily routines, streaks and repeatable behaviors.',
        metrics: const [
          SunyaModuleMetric(label: 'Active', value: '0', unit: 'habits', icon: Icons.repeat_outlined),
          SunyaModuleMetric(label: 'Completed', value: '0', unit: 'today', icon: Icons.check_circle_outline),
          SunyaModuleMetric(label: 'Best streak', value: '0', unit: 'days', icon: Icons.local_fire_department_outlined),
          SunyaModuleMetric(label: 'Consistency', value: '—', unit: '%', icon: Icons.insights_outlined),
        ],
      );
}
