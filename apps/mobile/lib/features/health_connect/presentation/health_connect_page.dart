import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_connect_service.dart';
import '../../../core/widgets/sunya_glass.dart';

final healthConnectServiceProvider = Provider((ref) => SunyaHealthConnectService());
final healthSnapshotProvider = FutureProvider<SunyaHealthSnapshot>((ref) => ref.watch(healthConnectServiceProvider).sync());

class HealthConnectPage extends ConsumerStatefulWidget {
  const HealthConnectPage({super.key});
  @override
  ConsumerState<HealthConnectPage> createState() => _HealthConnectPageState();
}

class _HealthConnectPageState extends ConsumerState<HealthConnectPage> {
  bool loading = false;
  String status = 'Connect Google Health Connect to import permitted data.';

  Future<void> connect() async {
    setState(() { loading = true; status = 'Checking supported health data…'; });
    try {
      final ok = await ref.read(healthConnectServiceProvider).requestReadAccess();
      if (!mounted) return;
      setState(() {
        loading = false;
        status = ok
            ? 'Connected. SUNYA can now analyse the data you approved.'
            : 'No supported permissions were granted. Retry or manage access in Health Connect.';
      });
      if (ok) ref.invalidate(healthSnapshotProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        status = 'Health Connect could not complete the connection. Try again after opening Health Connect.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(healthSnapshotProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Hub'),
        actions: [
          IconButton(onPressed: () => ref.invalidate(healthSnapshotProvider), icon: const Icon(Icons.sync_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          Text('Google Health data', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'SUNYA reads supported data from Android Health Connect. You choose the permissions; unavailable data types are skipped instead of blocking the connection.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          SunyaPrimaryButton(
            label: loading ? 'Connecting…' : 'Connect Google Health',
            onPressed: loading ? null : connect,
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(height: 10),
          Text(status),
          const SizedBox(height: 18),
          snapshot.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
            error: (e, _) => SunyaGlassCard(child: Text('Health data unavailable: $e')),
            data: (s) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _group(context, 'Activity', [
                  _Metric('Steps', '${s.steps}'),
                  _Metric('Distance', '${(s.distanceMeters / 1000).toStringAsFixed(1)} km'),
                  _Metric('Exercise', '${s.exerciseMinutes.round()} min'),
                  _Metric('Active kcal', '${s.activeCalories.round()}'),
                  _Metric('Total kcal', '${s.totalCalories.round()}'),
                ]),
                _group(context, 'Body', [
                  _Metric('Weight', s.weightKg == null ? '—' : '${s.weightKg!.toStringAsFixed(1)} kg'),
                  _Metric('Height', s.heightCm == null ? '—' : '${s.heightCm!.toStringAsFixed(0)} cm'),
                  _Metric('BMI', s.bmi == null ? '—' : s.bmi!.toStringAsFixed(1)),
                  _Metric('Body fat', s.bodyFatPercent == null ? '—' : '${s.bodyFatPercent!.toStringAsFixed(1)}%'),
                  _Metric('Body water', s.bodyWaterKg == null ? '—' : '${s.bodyWaterKg!.toStringAsFixed(1)} kg'),
                ]),
                _group(context, 'Vitals', [
                  _Metric('Heart rate', s.heartRate == null ? '—' : '${s.heartRate!.round()} bpm'),
                  _Metric('Resting HR', s.restingHeartRate == null ? '—' : '${s.restingHeartRate!.round()} bpm'),
                  _Metric('HRV', s.hrv == null ? '—' : '${s.hrv!.round()} ms'),
                  _Metric('SpO₂', s.oxygen == null ? '—' : '${s.oxygen!.round()}%'),
                  _Metric('Blood pressure', s.bloodPressureSystolic == null ? '—' : '${s.bloodPressureSystolic!.round()}/${s.bloodPressureDiastolic?.round() ?? '—'}'),
                  _Metric('Glucose', s.bloodGlucose == null ? '—' : '${s.bloodGlucose!.toStringAsFixed(1)} mg/dL'),
                  _Metric('Temperature', s.bodyTemperature == null ? '—' : '${s.bodyTemperature!.toStringAsFixed(1)} °C'),
                  _Metric('Respiratory', s.respiratoryRate == null ? '—' : '${s.respiratoryRate!.toStringAsFixed(1)}/min'),
                ]),
                _group(context, 'Sleep & nutrition', [
                  _Metric('Sleep', '${s.sleepHours.toStringAsFixed(1)} h'),
                  _Metric('Water', '${s.waterMl.round()} ml'),
                  _Metric('Food kcal', '${s.nutritionCalories.round()}'),
                  _Metric('Protein', '${s.nutritionProteinGrams.round()} g'),
                ]),
                SunyaGlassCard(
                  child: Text(
                    '${s.records} records imported from ${s.sourceNames.isEmpty ? s.source : s.sourceNames.join(', ')}. SUNYA analyses imported and user-entered data together; it does not diagnose conditions.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: children),
          ],
        ),
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 158,
        height: 92,
        child: SunyaGlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
}
