import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class BodyPage extends StatelessWidget {
  const BodyPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Body',
        description: 'Your physical baseline, measurements and composition history.',
        metrics: const [
          SunyaModuleMetric(label: 'Weight', value: '—', unit: 'kg', icon: Icons.monitor_weight_outlined),
          SunyaModuleMetric(label: 'Body fat', value: '—', unit: '%', icon: Icons.pie_chart_outline),
          SunyaModuleMetric(label: 'Height', value: '—', unit: 'cm', icon: Icons.height),
          SunyaModuleMetric(label: 'BMI', value: '—', unit: '', icon: Icons.calculate_outlined),
        ],
      );
}
