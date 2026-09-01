import 'package:flutter/material.dart';

import 'sunya_metric_card.dart';

class SunyaModuleMetric {
  const SunyaModuleMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
}

class SunyaModulePage extends StatelessWidget {
  const SunyaModulePage({
    super.key,
    required this.title,
    required this.description,
    required this.metrics,
    this.primaryAction,
  });

  final String title;
  final String description;
  final List<SunyaModuleMetric> metrics;
  final VoidCallback? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return SunyaMetricCard(
                label: metric.label,
                value: metric.value,
                unit: metric.unit,
                icon: metric.icon,
              );
            },
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: primaryAction,
              icon: const Icon(Icons.add),
              label: Text('Add $title entry'),
            ),
          ],
        ],
      ),
    );
  }
}
