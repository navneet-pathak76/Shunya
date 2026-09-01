import 'package:flutter/material.dart';

import '../../../core/widgets/sunya_module_page.dart';

class SleepPage extends StatelessWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context) => SunyaModulePage(
        title: 'Sleep',
        description: 'Sleep duration, consistency and recovery signals.',
        metrics: const [
          SunyaModuleMetric(label: 'Last night', value: '—', unit: 'h', icon: Icons.bedtime_outlined),
          SunyaModuleMetric(label: 'Target', value: '—', unit: 'h', icon: Icons.flag_outlined),
          SunyaModuleMetric(label: 'Quality', value: '—', unit: '/10', icon: Icons.hotel_outlined),
          SunyaModuleMetric(label: 'Streak', value: '0', unit: 'days', icon: Icons.nightlight_outlined),
        ],
      );
}
