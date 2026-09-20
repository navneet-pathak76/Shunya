import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/sunya_glass.dart';
import '../domain/appearance_snapshot.dart';
import 'appearance_controller.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(appearanceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        actions: [
          IconButton(
            tooltip: 'Appearance plan',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AppearancePlanPage()),
            ),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _capture(context, ref),
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Daily check-in'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Text('Know your face, hair and skin over time.',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          const Text(
            'SUNYA tracks visual trends and your own observations. It does not diagnose skin or hair disease.',
          ),
          const SizedBox(height: 18),
          const _ProtocolCard(),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 18),
            _TrendCard(items: items),
            const SizedBox(height: 18),
          ],
          if (items.isEmpty)
            const SunyaGlassCard(
              padding: EdgeInsets.all(20),
              child: Text(
                'No appearance baseline yet. Take the first controlled photo today.',
              ),
            )
          else
            ...items.take(30).map(
                  (item) => _SnapshotCard(
                    item: item,
                    onDelete: () => ref
                        .read(appearanceProvider.notifier)
                        .delete(item.id),
                  ),
                ),
        ],
      ),
    );
  }

  static Future<void> _capture(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (file == null || !context.mounted) return;

    final bytes = await file.readAsBytes();
    if (!context.mounted) return;

    final checkIn = await showDialog<_AppearanceCheckIn>(
      context: context,
      builder: (_) => const _AppearanceCheckInDialog(),
    );
    if (checkIn == null) return;

    await ref.read(appearanceProvider.notifier).add(
          path: file.path,
          imageBytes: bytes,
          area: AppearanceArea.face,
          notes: checkIn.notes,
          userScore: checkIn.userScore,
          hairDensityScore: checkIn.hairDensity,
          beardCoverageScore: checkIn.beardCoverage,
          underEyeScore: checkIn.underEye,
          skinClarityScore: checkIn.skinClarity,
          hairShedding: checkIn.hairShedding,
          scalpItch: checkIn.scalpItch,
          scalpFlaking: checkIn.scalpFlaking,
          sleepHours: checkIn.sleepHours,
        );
  }
}

class _ProtocolCard extends StatelessWidget {
  const _ProtocolCard();

  @override
  Widget build(BuildContext context) => const SunyaGlassCard(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily capture protocol',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 10),
            Text(
              'Use the same camera, distance, lighting and neutral expression. '
              'Keep hair styling consistent. Capture front face, hairline and beard area. Avoid filters.',
            ),
            SizedBox(height: 10),
            Text(
              'Track: hairline • density • beard coverage • under-eye appearance • skin clarity',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.items});
  final List<AppearanceSnapshot> items;

  String change(double? latest, double? previous) {
    if (latest == null || previous == null) return '—';
    final d = latest - previous;
    if (d.abs() < .05) return 'Stable';
    return d > 0 ? 'Up ${d.toStringAsFixed(1)}' : 'Down ${d.abs().toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final latest = items.first;
    final previous = items.length > 1 ? items[1] : null;
    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trend snapshot',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${items.length} saved check-in${items.length == 1 ? '' : 's'}'),
          const SizedBox(height: 12),
          _Metric('Hair density', latest.hairDensityScore,
              change(latest.hairDensityScore, previous?.hairDensityScore)),
          _Metric('Beard coverage', latest.beardCoverageScore,
              change(latest.beardCoverageScore, previous?.beardCoverageScore)),
          _Metric('Under-eye', latest.underEyeScore,
              change(latest.underEyeScore, previous?.underEyeScore)),
          _Metric('Skin clarity', latest.skinClarityScore,
              change(latest.skinClarityScore, previous?.skinClarityScore)),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.change);
  final String label;
  final double? value;
  final String change;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value == null ? '—' : value!.toStringAsFixed(1)),
            const SizedBox(width: 12),
            SizedBox(width: 65, child: Text(change, textAlign: TextAlign.right)),
          ],
        ),
      );
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({required this.item, required this.onDelete});
  final AppearanceSnapshot item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    Widget image = const Icon(Icons.image_not_supported_outlined);
    final encoded = item.imageDataBase64;
    if (encoded != null && encoded.isNotEmpty) {
      try {
        image = Image.memory(
          base64Decode(encoded),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined),
        );
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SunyaGlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.capturedAt.toLocal().toString().split('.').first,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(item.notes.isEmpty
                      ? 'Controlled appearance snapshot'
                      : item.notes),
                  const SizedBox(height: 5),
                  Text(
                    'Hair ${item.hairDensityScore?.toStringAsFixed(1) ?? '—'} • '
                    'Beard ${item.beardCoverageScore?.toStringAsFixed(1) ?? '—'} • '
                    'Under-eye ${item.underEyeScore?.toStringAsFixed(1) ?? '—'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceCheckIn {
  const _AppearanceCheckIn({
    required this.userScore,
    required this.hairDensity,
    required this.beardCoverage,
    required this.underEye,
    required this.skinClarity,
    required this.hairShedding,
    required this.scalpItch,
    required this.scalpFlaking,
    required this.sleepHours,
    required this.notes,
  });
  final double userScore;
  final double hairDensity;
  final double beardCoverage;
  final double underEye;
  final double skinClarity;
  final double hairShedding;
  final bool scalpItch;
  final bool scalpFlaking;
  final double sleepHours;
  final String notes;
}

class _AppearanceCheckInDialog extends StatefulWidget {
  const _AppearanceCheckInDialog();

  @override
  State<_AppearanceCheckInDialog> createState() =>
      _AppearanceCheckInDialogState();
}

class _AppearanceCheckInDialogState extends State<_AppearanceCheckInDialog> {
  final notes = TextEditingController();
  double userScore = 5, hairDensity = 5, beardCoverage = 5, underEye = 5;
  double skinClarity = 5, hairShedding = 0, sleepHours = 7;
  bool scalpItch = false, scalpFlaking = false;

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  Widget slider(String label, double value, ValueChanged<double> onChanged) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(label)), Text(value.toStringAsFixed(1))]),
          Slider(value: value, min: 0, max: 10, divisions: 20, onChanged: onChanged),
        ],
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Daily appearance check-in'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Use the same scale each day. These are tracking scores, not medical measurements.',
              ),
              const SizedBox(height: 10),
              slider('Overall appearance', userScore, (v) => setState(() => userScore = v)),
              slider('Hair density', hairDensity, (v) => setState(() => hairDensity = v)),
              slider('Beard coverage', beardCoverage, (v) => setState(() => beardCoverage = v)),
              slider('Under-eye appearance', underEye, (v) => setState(() => underEye = v)),
              slider('Skin clarity', skinClarity, (v) => setState(() => skinClarity = v)),
              slider('Hair shedding', hairShedding, (v) => setState(() => hairShedding = v)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scalp itching'),
                value: scalpItch,
                onChanged: (v) => setState(() => scalpItch = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Scalp flaking'),
                value: scalpFlaking,
                onChanged: (v) => setState(() => scalpFlaking = v),
              ),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Sleep last night (hours)'),
                onChanged: (v) => sleepHours = double.tryParse(v) ?? sleepHours,
              ),
              TextField(
                controller: notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Anything noticeably different today?',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _AppearanceCheckIn(
                userScore: userScore,
                hairDensity: hairDensity,
                beardCoverage: beardCoverage,
                underEye: underEye,
                skinClarity: skinClarity,
                hairShedding: hairShedding,
                scalpItch: scalpItch,
                scalpFlaking: scalpFlaking,
                sleepHours: sleepHours,
                notes: notes.text.trim(),
              ),
            ),
            child: const Text('Save check-in'),
          ),
        ],
      );
}

class AppearancePlanPage extends StatelessWidget {
  const AppearancePlanPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Appearance plan')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            _PlanTile('Standardize first',
                'Same camera, distance, lighting, expression and hairstyle before comparing photos.'),
            _PlanTile('Use longitudinal trends',
                'Use repeated check-ins and compare 7-, 30- and 90-day periods instead of judging one selfie.'),
            _PlanTile('Hair and scalp',
                'Track hairline, density, shedding, itch and flaking separately. A trend does not establish the cause.'),
            _PlanTile('Beard',
                'Keep beard length and lighting consistent when comparing coverage.'),
            _PlanTile('Under-eyes and skin',
                'Log sleep and environmental changes alongside the photo so visual changes have context.'),
            _PlanTile('Escalation',
                'Rapid or patchy hair loss, scalp pain or inflammation, or a rapidly changing skin lesion should be assessed by an appropriate clinician rather than judged by SUNYA.'),
          ],
        ),
      );
}

class _PlanTile extends StatelessWidget {
  const _PlanTile(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SunyaGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text(body),
            ],
          ),
        ),
      );
}
