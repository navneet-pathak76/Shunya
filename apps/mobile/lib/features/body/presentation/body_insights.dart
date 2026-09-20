import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../domain/entities/body_region_measurement.dart';
import 'body_controller.dart';

class BodyInsights extends ConsumerWidget {
  const BodyInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyProvider);
    final spots = state.measurements.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList();
    final latest = <BodyRegion, BodyRegionMeasurement>{};
    for (final item in state.regionMeasurements) latest[item.region] = item;
    final pairs = <String, double>{};
    const pairDefs = [
      ('Biceps', BodyRegion.leftBiceps, BodyRegion.rightBiceps),
      ('Forearm', BodyRegion.leftForearm, BodyRegion.rightForearm),
      ('Thigh', BodyRegion.leftThigh, BodyRegion.rightThigh),
      ('Calf', BodyRegion.leftCalf, BodyRegion.rightCalf),
    ];
    for (final pair in pairDefs) {
      final left = latest[pair.$2]?.centimetres, right = latest[pair.$3]?.centimetres;
      if (left != null && right != null) pairs[pair.$1] = (left - right).abs();
    }

    return Column(children: [
      SunyaGlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.insights_rounded, color: SunyaTheme.orange),
            const SizedBox(width: 10),
            Text('Body trends', style: Theme.of(context).textTheme.titleLarge),
          ]),
          const SizedBox(height: 6),
          Text('Weight history becomes a trend once SUNYA has multiple observations.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: spots.length < 2
                ? Center(child: Text('Record at least two weight measurements to see a trend.',
                    style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center))
                : LineChart(LineChartData(
                    minX: 0, maxX: (spots.length - 1).toDouble(),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [LineChartBarData(
                      spots: spots, isCurved: true, barWidth: 3,
                      dotData: const FlDotData(show: false), color: SunyaTheme.orange,
                    )],
                  )),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      SunyaGlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Symmetry', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Absolute left/right circumference difference for paired regions.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          if (pairs.isEmpty) const Text('Measure both sides of a paired region to calculate symmetry.')
          else ...pairs.entries.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.key),
            trailing: Text('${e.value.toStringAsFixed(1)} cm',
              style: Theme.of(context).textTheme.titleMedium),
          )),
        ]),
      ),
    ]);
  }
}
