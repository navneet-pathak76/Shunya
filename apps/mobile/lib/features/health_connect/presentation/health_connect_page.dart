import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/health_connect_service.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../../core/widgets/sunya_logo.dart';

final healthConnectServiceProvider = Provider((ref) => SunyaHealthConnectService());
final healthSnapshotProvider = FutureProvider<SunyaHealthSnapshot>(
  (ref) => ref.watch(healthConnectServiceProvider).sync(),
);

class HealthConnectPage extends ConsumerStatefulWidget {
  const HealthConnectPage({super.key});
  @override ConsumerState<HealthConnectPage> createState() => _HealthConnectPageState();
}

class _HealthConnectPageState extends ConsumerState<HealthConnectPage> {
  bool loading = false;
  String status = 'Choose automatic health sync or enter data manually.';

  Future<void> connect() async {
    setState(() => loading = true);
    final ok = await ref.read(healthConnectServiceProvider).requestReadAccess();
    if (!mounted) return;
    setState(() {
      loading = false;
      status = ok
          ? 'Google Health Connect permissions granted.'
          : 'No compatible Health Connect data type was available or permission was denied.';
    });
    if (ok) ref.invalidate(healthSnapshotProvider);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(healthSnapshotProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Hub'),
        actions: [IconButton(onPressed: () => ref.invalidate(healthSnapshotProvider), icon: const Icon(Icons.sync))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const SunyaLogo(size: 72),
          const SizedBox(height: 18),
          Text('Your health data', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text('SUNYA can build your baseline in two ways: securely import permitted data from Google Health Connect, or let you enter and correct information manually.'),
          const SizedBox(height: 18),
          SunyaGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.health_and_safety_outlined, color: SunyaTheme.gold), SizedBox(width: 10), Text('Option 1  •  Google Health', style: TextStyle(fontWeight: FontWeight.w700))]),
                const SizedBox(height: 10),
                const Text('Import activity, sleep, body measurements, hydration and supported vitals. Permissions remain controlled by Android Health Connect.'),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: loading ? null : connect,
                    icon: const Icon(Icons.favorite_outline),
                    label: Text(loading ? 'Connecting…' : 'Connect Google Health'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(status, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SunyaGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.edit_note_rounded, color: SunyaTheme.gold), SizedBox(width: 10), Text('Option 2  •  Enter manually', style: TextStyle(fontWeight: FontWeight.w700))]),
                const SizedBox(height: 10),
                const Text('Add body measurements, meals, hydration, sleep and other information yourself. SUNYA analyzes manual and imported data together.'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(label: const Text('Body'), onPressed: () => context.push('/body')),
                    ActionChip(label: const Text('Nutrition'), onPressed: () => context.push('/nutrition')),
                    ActionChip(label: const Text('Hydration'), onPressed: () => context.push('/hydration')),
                    ActionChip(label: const Text('Sleep'), onPressed: () => context.push('/sleep')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          snapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SunyaGlassCard(child: Text('Health sync unavailable: ' + e.toString())),
            data: (s) => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric('Steps', s.steps.toString()),
                _Metric('Active kcal', s.activeCalories.round().toString()),
                _Metric('Water', s.waterMl.round().toString() + ' ml'),
                _Metric('Sleep', s.sleepHours.toStringAsFixed(1) + ' h'),
                _Metric('Weight', s.weightKg == null ? '—' : s.weightKg!.toStringAsFixed(1) + ' kg'),
                _Metric('Heart rate', s.heartRate == null ? '—' : s.heartRate!.round().toString() + ' bpm'),
                _Metric('Resting HR', s.restingHeartRate == null ? '—' : s.restingHeartRate!.round().toString() + ' bpm'),
                _Metric('HRV', s.hrv == null ? '—' : s.hrv!.round().toString() + ' ms'),
                _Metric('SpO₂', s.oxygen == null ? '—' : s.oxygen!.round().toString() + '%'),
                _Metric('Records', s.records.toString()),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SunyaGlassCard(child: Text('SUNYA uses imported and user-entered data for tracking, analysis and personalization. It does not diagnose medical conditions.')),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 155,
        height: 100,
        child: SunyaGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      );
}
