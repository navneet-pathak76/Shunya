import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../domain/entities/body_region_measurement.dart';
import 'body_controller.dart';

class BodyRegionSection extends ConsumerWidget {
  const BodyRegionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regions = ref.watch(bodyProvider).regionMeasurements;
    final latest = <BodyRegion, BodyRegionMeasurement>{};

    for (final item in regions) {
      latest[item.region] = item;
    }

    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten_rounded, color: SunyaTheme.orange),
              const SizedBox(width: 10),
              Text('Body measurements', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                tooltip: 'Add measurement',
                onPressed: () => _add(context, ref),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Track circumference and symmetry by body region.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (latest.isEmpty)
            const Text('No regional measurements yet.')
          else
            ...BodyRegion.values.where(latest.containsKey).map(
              (region) {
                final item = latest[region]!;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(region.label),
                  subtitle: Text(
                    item.recordedAt.toLocal().toString().split('.').first,
                  ),
                  trailing: Text(
                    '${item.centimetres.toStringAsFixed(1)} cm',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  static Future<void> _add(BuildContext context, WidgetRef ref) async {
    var selected = BodyRegion.waist;
    final value = TextEditingController();
    final note = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Regional measurement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<BodyRegion>(
                  value: selected,
                  decoration: const InputDecoration(labelText: 'Body region'),
                  items: BodyRegion.values
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region.label),
                          ))
                      .toList(),
                  onChanged: (region) {
                    if (region != null) setState(() => selected = region);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Circumference (cm)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: note,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final centimetres = double.tryParse(value.text);
                if (centimetres == null || centimetres <= 0) return;
                await ref.read(bodyProvider.notifier).saveRegion(
                      region: selected,
                      centimetres: centimetres,
                      note: note.text.trim(),
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    value.dispose();
    note.dispose();
  }
}
