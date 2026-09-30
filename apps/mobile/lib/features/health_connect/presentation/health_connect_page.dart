import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_connect_service.dart';
import '../../../core/widgets/sunya_glass.dart';

final healthConnectServiceProvider = Provider((ref) => SunyaHealthConnectService());
final healthSnapshotProvider = FutureProvider<SunyaHealthSnapshot>((ref) => ref.watch(healthConnectServiceProvider).sync());

class HealthConnectPage extends ConsumerStatefulWidget {
  const HealthConnectPage({super.key});
  @override ConsumerState<HealthConnectPage> createState() => _HealthConnectPageState();
}
class _HealthConnectPageState extends ConsumerState<HealthConnectPage> {
  bool loading = false;
  String status = 'Connect a health platform to import permitted data.';
  Future<void> connect() async {
    setState(() => loading = true);
    final ok = await ref.read(healthConnectServiceProvider).requestReadAccess();
    if (!mounted) return;
    setState(() { loading = false; status = ok ? 'Permissions granted.' : 'Permission was not granted or the platform is unavailable.'; });
    if (ok) ref.invalidate(healthSnapshotProvider);
  }
  @override Widget build(BuildContext context) {
    final snapshot = ref.watch(healthSnapshotProvider);
    return Scaffold(appBar: AppBar(title: const Text('Health Hub'), actions: [IconButton(onPressed: () => ref.invalidate(healthSnapshotProvider), icon: const Icon(Icons.sync))]), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Health data', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 8),
      const Text('Import activity, body, hydration, sleep and permitted vitals into SUNYA. Permissions remain controlled by the health platform.'),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: loading ? null : connect, icon: const Icon(Icons.favorite_outline), label: Text(loading ? 'Connecting…' : 'Connect health data')),
      const SizedBox(height: 10), Text(status), const SizedBox(height: 18),
      snapshot.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, _) => SunyaGlassCard(child: Text('Unavailable: $e')), data: (s) => Wrap(spacing: 12, runSpacing: 12, children: [
        _Metric('Steps', s.steps.toString()), _Metric('Active kcal', s.activeCalories.round().toString()), _Metric('Water', s.waterMl.round().toString() + ' ml'), _Metric('Sleep', s.sleepHours.toStringAsFixed(1) + ' h'), _Metric('Weight', s.weightKg == null ? '—' : s.weightKg!.toStringAsFixed(1) + ' kg'), _Metric('Heart rate', s.heartRate == null ? '—' : s.heartRate!.round().toString() + ' bpm'), _Metric('Resting HR', s.restingHeartRate == null ? '—' : s.restingHeartRate!.round().toString() + ' bpm'), _Metric('HRV', s.hrv == null ? '—' : s.hrv!.round().toString() + ' ms'), _Metric('SpO₂', s.oxygen == null ? '—' : s.oxygen!.round().toString() + '%'), _Metric('Records', s.records.toString()),
      ])),
      const SizedBox(height: 18),
      const SunyaGlassCard(child: Text('SUNYA does not diagnose conditions from these values. Health data is used for tracking, planning and personalization.')),
    ]));
  }
}
class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label, value;
  @override Widget build(BuildContext context) => SizedBox(width: 155, height: 100, child: SunyaGlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), const Spacer(), Text(value, style: Theme.of(context).textTheme.titleLarge)])));
}
