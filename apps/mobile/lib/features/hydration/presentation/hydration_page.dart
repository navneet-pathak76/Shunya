import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class HydrationPage extends StatelessWidget {
  const HydrationPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Hydration',
        description: 'Track water intake, targets and reminder progress.',
        metrics: const [
          SunyaModuleMetric(label: 'Today', value: '0', unit: 'ml', icon: Icons.water_drop_outlined),
          SunyaModuleMetric(label: 'Target', value: '—', unit: 'ml', icon: Icons.flag_outlined),
          SunyaModuleMetric(label: 'Entries', value: '0', unit: '', icon: Icons.format_list_numbered),
          SunyaModuleMetric(label: 'Reminders', value: 'Off', unit: '', icon: Icons.notifications_none),
        ],
      );
}
