import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../domain/entities/body_profile.dart';
import 'body_atlas.dart';
import 'body_controller.dart';
import 'body_insights.dart';
import 'body_region_section.dart';
import 'package:go_router/go_router.dart';

class BodyPage extends ConsumerWidget {
  const BodyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = ref.watch(bodyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Intelligence'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _editProfile(context, ref),
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Add measurement',
            onPressed: () => _editMeasurement(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 8),
          IconButton(tooltip: 'Body goals', onPressed: () => context.push('/body/goals'), icon: const Icon(Icons.flag_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Know your body.', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            'SUNYA builds a private longitudinal model of your body from measurements, composition and vitals.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          const BodyAtlas(),
          const SizedBox(height: 16),
          _OverviewCard(body: body),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Body composition',
            icon: Icons.pie_chart_outline_rounded,
            children: [
              _DataRow('Body fat', body.profile?.bodyFatPercent, '%'),
              _DataRow('Muscle mass', body.profile?.muscleMassKg, 'kg'),
              _DataRow('Body water', body.profile?.bodyWaterPercent, '%'),
              _DataRow('Bone mass', body.profile?.boneMassKg, 'kg'),
              _DataRow('Visceral fat', body.profile?.visceralFatLevel, 'level'),
              _DataRow('BMR', body.profile?.bmrKcal, 'kcal/day'),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Vitals',
            icon: Icons.monitor_heart_outlined,
            children: [
              _DataRow('Resting heart rate', body.profile?.restingHeartRateBpm, 'bpm'),
              _DataRow('Systolic BP', body.profile?.systolicBp, 'mmHg'),
              _DataRow('Diastolic BP', body.profile?.diastolicBp, 'mmHg'),
              _DataRow('Oxygen saturation', body.profile?.oxygenSaturationPercent, '%'),
              _DataRow('Temperature', body.profile?.bodyTemperatureC, '°C'),
            ],
          ),
          const SizedBox(height: 16),
          const BodyRegionSection(),
          const SizedBox(height: 16),
          const BodyInsights(),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Measurement history',
            icon: Icons.timeline_rounded,
            children: [
              if (body.measurements.isEmpty)
                const Text('No measurements yet.')
              else
                ...body.measurements.reversed.take(8).map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${item.weightKg.toStringAsFixed(1)} kg'),
                    subtitle: Text(
                      '${item.date.toLocal().toString().split('.').first} · BMI ${item.bmi.toStringAsFixed(1)}',
                    ),
                    trailing: Text('${item.bodyFatPercent.toStringAsFixed(1)}%'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _editMeasurement(BuildContext context, WidgetRef ref) async {
    final current = ref.read(bodyProvider);
    final weight = TextEditingController(text: current.weightKg?.toString() ?? '');
    final height = TextEditingController(text: current.heightCm?.toString() ?? '');
    final fat = TextEditingController(text: current.bodyFatPercent?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Record measurement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(weight, 'Weight (kg)'),
            _field(height, 'Height (cm)'),
            _field(fat, 'Body fat (%)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(bodyProvider.notifier).save(
                    weightKg: double.tryParse(weight.text),
                    heightCm: double.tryParse(height.text),
                    bodyFatPercent: double.tryParse(fat.text),
                  );
              Navigator.pop(dialogContext);
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

  static Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final current = ref.read(bodyProvider).profile;
    final fields = <String, TextEditingController>{
      'height': TextEditingController(text: current?.heightCm?.toString() ?? ''),
      'heart': TextEditingController(text: current?.restingHeartRateBpm?.toString() ?? ''),
      'sys': TextEditingController(text: current?.systolicBp?.toString() ?? ''),
      'dia': TextEditingController(text: current?.diastolicBp?.toString() ?? ''),
      'spo2': TextEditingController(text: current?.oxygenSaturationPercent?.toString() ?? ''),
      'fat': TextEditingController(text: current?.bodyFatPercent?.toString() ?? ''),
      'muscle': TextEditingController(text: current?.muscleMassKg?.toString() ?? ''),
      'water': TextEditingController(text: current?.bodyWaterPercent?.toString() ?? ''),
      'bone': TextEditingController(text: current?.boneMassKg?.toString() ?? ''),
      'visceral': TextEditingController(text: current?.visceralFatLevel?.toString() ?? ''),
      'bmr': TextEditingController(text: current?.bmrKcal?.toString() ?? ''),
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Body profile'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(fields['height']!, 'Height (cm)'),
                _field(fields['heart']!, 'Resting heart rate (bpm)'),
                _field(fields['sys']!, 'Systolic BP (mmHg)'),
                _field(fields['dia']!, 'Diastolic BP (mmHg)'),
                _field(fields['spo2']!, 'Oxygen saturation (%)'),
                _field(fields['fat']!, 'Body fat (%)'),
                _field(fields['muscle']!, 'Muscle mass (kg)'),
                _field(fields['water']!, 'Body water (%)'),
                _field(fields['bone']!, 'Bone mass (kg)'),
                _field(fields['visceral']!, 'Visceral fat level'),
                _field(fields['bmr']!, 'BMR (kcal/day)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final profile = BodyProfile(
                id: current?.id ?? 'profile',
                dateOfBirth: current?.dateOfBirth,
                biologicalSex: current?.biologicalSex,
                heightCm: double.tryParse(fields['height']!.text),
                restingHeartRateBpm: double.tryParse(fields['heart']!.text),
                systolicBp: double.tryParse(fields['sys']!.text),
                diastolicBp: double.tryParse(fields['dia']!.text),
                oxygenSaturationPercent: double.tryParse(fields['spo2']!.text),
                bodyTemperatureC: current?.bodyTemperatureC,
                bodyFatPercent: double.tryParse(fields['fat']!.text),
                muscleMassKg: double.tryParse(fields['muscle']!.text),
                bodyWaterPercent: double.tryParse(fields['water']!.text),
                boneMassKg: double.tryParse(fields['bone']!.text),
                visceralFatLevel: double.tryParse(fields['visceral']!.text),
                bmrKcal: double.tryParse(fields['bmr']!.text),
                notes: current?.notes ?? '',
                source: current?.source ?? BodyDataSource.manual,
                updatedAt: DateTime.now().toUtc(),
              );
              await ref.read(bodyProvider.notifier).saveProfile(profile);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save profile'),
          ),
        ],
      ),
    );

    for (final controller in fields.values) {
      controller.dispose();
    }
  }

  static Widget _field(TextEditingController controller, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
        ),
      );
}

class _BodyAtlasCard extends StatelessWidget {
  const _BodyAtlasCard();

  @override
  Widget build(BuildContext context) {
    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Body atlas', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'A visual map for region-specific measurements, goals and progress.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _Silhouette(label: 'FRONT')),
              SizedBox(width: 10),
              Expanded(child: _Silhouette(label: 'BACK')),
            ],
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Neck')),
              Chip(label: Text('Shoulders')),
              Chip(label: Text('Chest')),
              Chip(label: Text('Arms')),
              Chip(label: Text('Waist')),
              Chip(label: Text('Hips')),
              Chip(label: Text('Thighs')),
              Chip(label: Text('Calves')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Silhouette extends StatelessWidget {
  const _Silhouette({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
        const SizedBox(height: 6),
        const SizedBox(
          height: 240,
          child: CustomPaint(
            painter: _HumanSilhouettePainter(),
            child: SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _HumanSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = SunyaTheme.blueBright.withValues(alpha: .18)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = SunyaTheme.blueBright.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final s = size.height / 240;
    final cx = size.width / 2;

    canvas.drawCircle(Offset(cx, 22 * s), 17 * s, fill);
    canvas.drawCircle(Offset(cx, 22 * s), 17 * s, outline);

    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, 103 * s), width: 70 * s, height: 105 * s),
      Radius.circular(28 * s),
    );
    canvas.drawRRect(torso, fill);
    canvas.drawRRect(torso, outline);

    final limb = Paint()
      ..color = SunyaTheme.blueBright.withValues(alpha: .14)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 54 * s, 54 * s, 21 * s, 105 * s), Radius.circular(11 * s)),
      limb,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 33 * s, 54 * s, 21 * s, 105 * s), Radius.circular(11 * s)),
      limb,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 30 * s, 150 * s, 27 * s, 88 * s), Radius.circular(13 * s)),
      limb,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 3 * s, 150 * s, 27 * s, 88 * s), Radius.circular(13 * s)),
      limb,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.body});
  final BodyState body;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Weight', body.weightKg, 'kg'),
      ('Height', body.heightCm, 'cm'),
      ('BMI', body.bmi, ''),
      ('Body fat', body.bodyFatPercent, '%'),
    ];

    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: metrics.map((metric) {
          final value = metric.$2 == null ? '—' : '${metric.$2!.toStringAsFixed(1)}';
          return SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.$1, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 3),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                if (metric.$3.isNotEmpty)
                  Text(metric.$3, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SunyaTheme.blueBright),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow(this.label, this.value, this.unit);

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final display = value == null
        ? '—'
        : '${value!.toStringAsFixed(1)}${unit.isEmpty ? '' : ' $unit'}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(display, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
