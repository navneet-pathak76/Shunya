import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../domain/entities/body_region_measurement.dart';
import 'body_controller.dart';

class BodyAtlas extends ConsumerWidget {
  const BodyAtlas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyProvider);
    final latest = <BodyRegion, BodyRegionMeasurement>{};
    for (final item in state.regionMeasurements) { latest[item.region] = item; }

    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Body atlas', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Tap a region to record its latest circumference.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(children: const [
          Expanded(child: _AtlasView(label: 'FRONT')),
          SizedBox(width: 10),
          Expanded(child: _AtlasView(label: 'BACK')),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: BodyRegion.values.map((region) => ActionChip(
            avatar: Icon(latest[region] == null ? Icons.add_rounded : Icons.check_rounded, size: 16),
            label: Text(region.label),
            onPressed: () => _add(context, ref, region),
          )).toList(),
        ),
      ]),
    );
  }

  static Future<void> _add(BuildContext context, WidgetRef ref, BodyRegion region) async {
    final value = TextEditingController();
    final note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${region.label} measurement'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: value, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Circumference (cm)')),
          const SizedBox(height: 10),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Note (optional)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            final cm = double.tryParse(value.text);
            if (cm == null || cm <= 0) return;
            await ref.read(bodyProvider.notifier).saveRegion(region: region, centimetres: cm, note: note.text.trim());
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          }, child: const Text('Save')),
        ],
      ),
    );
    value.dispose(); note.dispose();
  }
}

class _AtlasView extends StatelessWidget {
  const _AtlasView({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2)),
    const SizedBox(height: 6),
    SizedBox(height: 240, child: CustomPaint(painter: _AtlasPainter(), child: const SizedBox.expand())),
  ]);
}

class _AtlasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 240, cx = size.width / 2;
    final fill = Paint()..color = SunyaTheme.orange.withValues(alpha: .16)..style = PaintingStyle.fill;
    final line = Paint()..color = SunyaTheme.orange.withValues(alpha: .55)..style = PaintingStyle.stroke..strokeWidth = 1.4;
    canvas.drawCircle(Offset(cx, 22 * s), 17 * s, fill);
    canvas.drawCircle(Offset(cx, 22 * s), 17 * s, line);
    final torso = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, 103 * s), width: 70 * s, height: 105 * s), Radius.circular(28 * s));
    canvas.drawRRect(torso, fill); canvas.drawRRect(torso, line);
    final limb = Paint()..color = SunyaTheme.orange.withValues(alpha: .12)..style = PaintingStyle.fill;
    for (final rect in [
      Rect.fromLTWH(cx - 54 * s, 54 * s, 21 * s, 105 * s),
      Rect.fromLTWH(cx + 33 * s, 54 * s, 21 * s, 105 * s),
      Rect.fromLTWH(cx - 30 * s, 150 * s, 27 * s, 88 * s),
      Rect.fromLTWH(cx + 3 * s, 150 * s, 27 * s, 88 * s),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(12 * s)), limb);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
