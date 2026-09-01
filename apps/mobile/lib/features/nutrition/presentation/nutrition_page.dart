import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Nutrition',
        description: 'Meals, calories, macros and nutrition goals for the day.',
        metrics: const [
          SunyaModuleMetric(label: 'Calories', value: '0', unit: 'kcal', icon: Icons.local_fire_department_outlined),
          SunyaModuleMetric(label: 'Protein', value: '0', unit: 'g', icon: Icons.fitness_center_outlined),
          SunyaModuleMetric(label: 'Meals', value: '0', unit: '', icon: Icons.restaurant_outlined),
          SunyaModuleMetric(label: 'Goal', value: '—', unit: 'kcal', icon: Icons.flag_outlined),
        ],
      );
}
