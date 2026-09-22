import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sunya_glass.dart';
import 'sleep_controller.dart';

class SleepPage extends ConsumerWidget {
  const SleepPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sleepProvider);
    final latest = state.latest;
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add), label: const Text('Log sleep'),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Recovery starts at night.', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 6),
        Text('Track duration, timing and perceived sleep quality.', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _Stat('Last night', latest == null ? '—' : '${latest.hours.toStringAsFixed(1)} h')),
          const SizedBox(width: 10),
          Expanded(child: _Stat('Average', state.entries.isEmpty ? '—' : '${state.averageHours.toStringAsFixed(1)} h')),
          const SizedBox(width: 10),
          Expanded(child: _Stat('Quality', latest == null ? '—' : '${latest.quality}/10')),
        ]),
        const SizedBox(height: 20),
        if (state.entries.isEmpty)
          const SunyaGlassCard(padding: EdgeInsets.all(20), child: Text('No sleep records yet. Add your actual sleep window instead of using an automatic estimate.'))
        else
          ...state.entries.take(14).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SunyaGlassCard(padding: const EdgeInsets.all(16), child: Row(children: [
              const Icon(Icons.bedtime_outlined), const SizedBox(width: 12),
              Expanded(child: Text('${e.hours.toStringAsFixed(1)} h\n${_dateLabel(e.endedAt)}')),
              Text('${e.quality}/10', style: Theme.of(context).textTheme.titleMedium),
            ])),
          )),
      ]),
    );
  }

  static String _dateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Future<void> _add(BuildContext context, WidgetRef ref) async {
    DateTime start = DateTime.now().subtract(const Duration(hours: 8));
    DateTime end = DateTime.now();
    double quality = 7;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setState) => AlertDialog(
        title: const Text('Log sleep'),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _TimeRow(label: 'Sleep start', value: start, onPick: () async {
            final p = await _pickDateTime(context, start); if (p != null) setState(() => start = p);
          }),
          _TimeRow(label: 'Wake time', value: end, onPick: () async {
            final p = await _pickDateTime(context, end); if (p != null) setState(() => end = p);
          }),
          const SizedBox(height: 12),
          Text('Quality: ${quality.round()}/10'),
          Slider(value: quality, min: 1, max: 10, divisions: 9, label: quality.round().toString(), onChanged: (v) => setState(() => quality = v)),
          if (!end.isAfter(start)) const Text('Wake time must be after sleep start.'),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: end.isAfter(start) ? () => Navigator.pop(dialogContext, true) : null, child: const Text('Save')),
        ],
      )),
    );
    if (saved == true) await ref.read(sleepProvider.notifier).add(start: start, end: end, quality: quality.round());
  }

  static Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
    final date = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
    if (date == null || !context.mounted) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.value, required this.onPick});
  final String label; final DateTime value; final VoidCallback onPick;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero, title: Text(label),
    subtitle: Text(value.toLocal().toString().substring(0, 16)),
    trailing: OutlinedButton(onPressed: onPick, child: const Text('Change')),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => SunyaGlassCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label), const SizedBox(height: 5), Text(value, style: Theme.of(context).textTheme.titleLarge),
  ]));
}
