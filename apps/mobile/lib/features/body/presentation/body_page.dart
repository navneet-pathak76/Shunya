import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_motion.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import 'body_controller.dart';

class BodyPage extends ConsumerWidget {
  const BodyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = ref.watch(bodyProvider);
    final hasData = body.weightKg != null || body.heightCm != null || body.bodyFatPercent != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body'),
        actions: [
          IconButton(tooltip: 'Update', onPressed: () => _edit(context, ref), icon: const Icon(Icons.edit_outlined)),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('Your physical baseline', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text('Track the measurements that describe your current body.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 22),
          if (!hasData)
            SunyaGlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.accessibility_new_rounded, size: 34, color: SunyaTheme.orange),
                  const SizedBox(height: 16),
                  Text('Start your baseline', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text('Add your weight, height and body-fat data. SUNYA will use this as the foundation for future trends.', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 18),
                  SunyaPrimaryButton(label: 'Add measurement', onPressed: () => _edit(context, ref), icon: Icons.add_rounded),
                ],
              ),
            )
          else ...[
            _BodyHero(body: body),
            const SizedBox(height: 14),
            _MetricGrid(body: body),
          ],
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
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)')),
              TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height (cm)')),
              TextField(controller: fat, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Body fat (%)')),
            ],
          ),
        ),
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

class _BodyHero extends StatelessWidget {
  const _BodyHero({required this.body});
  final BodyState body;

  @override
  Widget build(BuildContext context) {
    return SunyaFadeSlide(
      child: SunyaGlassCard(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [SunyaTheme.orangeBright, SunyaTheme.orangeDeep]),
                boxShadow: [BoxShadow(color: SunyaTheme.orange.withOpacity(0.24), blurRadius: 24)],
              ),
              child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current weight', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text('${body.weightKg?.toStringAsFixed(1) ?? '—'} kg', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 3),
                  Text(body.bmi == null ? 'BMI not available' : 'BMI ${body.bmi!.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.body});
  final BodyState body;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Weight', body.weightKg == null ? '—' : body.weightKg!.toStringAsFixed(1), 'kg', Icons.monitor_weight_outlined),
      ('Height', body.heightCm == null ? '—' : body.heightCm!.toStringAsFixed(0), 'cm', Icons.height_rounded),
      ('Body fat', body.bodyFatPercent == null ? '—' : body.bodyFatPercent!.toStringAsFixed(1), '%', Icons.pie_chart_outline_rounded),
      ('BMI', body.bmi == null ? '—' : body.bmi!.toStringAsFixed(1), '', Icons.calculate_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.45),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return SunyaGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(metric.$4, color: SunyaTheme.orange),
              const Spacer(),
              Text(metric.$1, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 3),
              Text(metric.$2, style: Theme.of(context).textTheme.headlineSmall),
              if (metric.$3.isNotEmpty) Text(metric.$3, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
