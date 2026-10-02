import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/health_connect_service.dart';
import '../../../core/widgets/sunya_glass.dart';

final healthConnectServiceProvider = Provider((ref) => SunyaHealthConnectService());
final healthSnapshotProvider =
    FutureProvider<SunyaHealthSnapshot>((ref) => ref.watch(healthConnectServiceProvider).sync());

class HealthConnectPage extends ConsumerStatefulWidget {
  const HealthConnectPage({super.key});

  @override
  ConsumerState<HealthConnectPage> createState() => _HealthConnectPageState();
}

class _HealthConnectPageState extends ConsumerState<HealthConnectPage> {
  bool loading = false;
  String status = 'Connect Google Health Connect to import permitted data.';

  Future<void> connect() async {
    setState(() => loading = true);
    try {
      final available = await ref.read(healthConnectServiceProvider).available;
      if (!available) {
        if (mounted) {
          setState(() {
            loading = false;
            status = 'Health Connect is not available on this device.';
          });
        }
        return;
      }

      final ok = await ref.read(healthConnectServiceProvider).requestReadAccess();
      if (!mounted) return;
      setState(() {
        loading = false;
        status = ok
            ? 'Health Connect connected. SUNYA will use only the permissions you grant.'
            : 'Permission was not granted. You can retry or manage access in Health Connect.';
      });
      if (ok) ref.invalidate(healthSnapshotProvider);
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          status = 'Health Connect connection failed: ' + e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(healthSnapshotProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Hub'),
        actions: [
          IconButton(
            tooltip: 'Sync',
            onPressed: () => ref.invalidate(healthSnapshotProvider),
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Health data', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            'Option 1: import data from Google Health Connect. Option 2: enter data directly in SUNYA. '
            'Both sources become part of the same personal health context for analysis.',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: loading ? null : connect,
            icon: const Icon(Icons.health_and_safety_outlined),
            label: Text(loading ? 'Connecting…' : 'Connect Google Health Connect'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push('/body'),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Enter health data manually'),
          ),
          const SizedBox(height: 10),
          Text(status),
          const SizedBox(height: 16),
          snapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SunyaGlassCard(
              child: Text('Health data unavailable: ' + e.toString()),
            ),
            data: (s) => Column(
              children: [
                _group(
                  context,
                  'Movement',
                  [
                    _Metric('Steps', s.steps.toString()),
                    _Metric('Distance', _distance(s.distanceMeters)),
                    _Metric('Exercise', s.exerciseMinutes.toStringAsFixed(0) + ' min'),
                    _Metric('Active kcal', s.activeCalories.round().toString()),
                    _Metric('Total kcal', s.totalCalories.round().toString()),
                  ],
                ),
                _group(
                  context,
                  'Body',
                  [
                    _Metric('Weight', _number(s.weightKg, 'kg')),
                    _Metric('Height', _number(s.heightCm, 'cm')),
                    _Metric('Body fat', _number(s.bodyFatPercent, '%')),
                    _Metric('BMI', _number(s.bmi, '')),
                    _Metric('Waist', _number(s.waistCm, 'cm')),
                    _Metric('Body water', _number(s.bodyWaterKg, 'kg')),
                  ],
                ),
                _group(
                  context,
                  'Vitals',
                  [
                    _Metric('Heart rate', _number(s.heartRate, 'bpm')),
                    _Metric('Resting HR', _number(s.restingHeartRate, 'bpm')),
                    _Metric('HRV', _number(s.hrv, 'ms')),
                    _Metric('SpO₂', _number(s.oxygen, '%')),
                    _Metric('Blood pressure', _bp(s)),
                    _Metric('Glucose', _number(s.bloodGlucose, 'mg/dL')),
                    _Metric('Temperature', _number(s.bodyTemperature, '°C')),
                    _Metric('Respiratory', _number(s.respiratoryRate, '/min')),
                  ],
                ),
                _group(
                  context,
                  'Recovery & nutrition',
                  [
                    _Metric('Sleep', s.sleepHours.toStringAsFixed(1) + ' h'),
                    _Metric('Water', s.waterMl.round().toString() + ' ml'),
                    _Metric('Basal kcal', s.basalCalories.round().toString()),
                    _Metric('Records', s.records.toString()),
                  ],
                ),
                if (s.sourceNames.isNotEmpty)
                  SunyaGlassCard(
                    child: Text(
                      'Data sources: ' + s.sourceNames.join(', '),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SunyaGlassCard(
            child: Text(
              'SUNYA does not require every permission to work. If a data type is unavailable or denied, '
              'it is excluded instead of blocking the rest of the sync. Imported health data is used for '
              'tracking, personalization and planning; it does not diagnose conditions.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> metrics) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SunyaGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: metrics),
          ],
        ),
      ),
    );
  }

  String _number(double? value, String unit) =>
      value == null ? '—' : value.toStringAsFixed(1) + unit;

  String _distance(double meters) =>
      meters <= 0 ? '—' : (meters / 1000).toStringAsFixed(1) + ' km';

  String _bp(SunyaHealthSnapshot s) {
    if (s.bloodPressureSystolic == null || s.bloodPressureDiastolic == null) return '—';
    return s.bloodPressureSystolic!.round().toString() +
        '/' +
        s.bloodPressureDiastolic!.round().toString();
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      height: 88,
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
}
