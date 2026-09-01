import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'body_controller.dart';

class BodyPage extends ConsumerWidget {
  const BodyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = ref.watch(bodyProvider);
    final controller = ref.read(bodyProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Body')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Update'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Physical baseline', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('Track the measurements that describe your current body.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          _Metric(label: 'Weight', value: body.weightKg == null ? '—' : '${body.weightKg!.toStringAsFixed(1)} kg', icon: Icons.monitor_weight_outlined),
          _Metric(label: 'Height', value: body.heightCm == null ? '—' : '${body.heightCm!.toStringAsFixed(0)} cm', icon: Icons.height),
          _Metric(label: 'Body fat', value: body.bodyFatPercent == null ? '—' : '${body.bodyFatPercent!.toStringAsFixed(1)}%', icon: Icons.pie_chart_outline),
          _Metric(label: 'BMI', value: body.bmi == null ? '—' : body.bmi!.toStringAsFixed(1), icon: Icons.calculate_outlined),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: controller.state.weightKg == null ? () => _edit(context, ref) : null, icon: const Icon(Icons.add), label: const Text('Add your first measurement')),
        ],
      ),
    );
  }

  static Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final body = ref.read(bodyProvider);
    final weight = TextEditingController(text: body.weightKg?.toString() ?? '');
    final height = TextEditingController(text: body.heightCm?.toString() ?? '');
    final fat = TextEditingController(text: body.bodyFatPercent?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update body'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)')),
          TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height (cm)')),
          TextField(controller: fat, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Body fat (%)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(bodyProvider.notifier).save(
                    weightKg: double.tryParse(weight.text),
                    heightCm: double.tryParse(height.text),
                    bodyFatPercent: double.tryParse(fat.text),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    weight.dispose();
    height.dispose();
    fat.dispose();
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(leading: Icon(icon), title: Text(label), trailing: Text(value, style: Theme.of(context).textTheme.titleMedium)),
      );
}
