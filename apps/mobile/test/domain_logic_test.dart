import 'package:flutter_test/flutter_test.dart';

import 'package:sunya/features/body/domain/entities/body_measurement.dart';
import 'package:sunya/features/hydration/domain/entities/hydration_entry.dart';

void main() {
  group('SUNYA domain logic', () {
    test('calculates BMI from height and weight', () {
      final measurement = BodyMeasurement(
        id: 'body-1',
        date: DateTime(2026, 9, 18),
        weightKg: 72.5,
        heightCm: 178,
        bodyFatPercent: 17.3,
      );

      expect(measurement.bmi, closeTo(22.9, 0.1));
    });

    test('calculates hydration progress for a target', () {
      final summary = HydrationSummary(
        targetMl: 2500,
        entries: [
          HydrationEntry(id: 'a', amountMl: 500, recordedAt: DateTime(2026, 9, 18, 8, 0)),
          HydrationEntry(id: 'b', amountMl: 750, recordedAt: DateTime(2026, 9, 18, 12, 0)),
          HydrationEntry(id: 'c', amountMl: 250, recordedAt: DateTime(2026, 9, 18, 18, 0)),
        ],
      );

      expect(summary.totalConsumedMl, 1500);
      expect(summary.progress, closeTo(0.6, 0.01));
      expect(summary.percentComplete, 60);
    });
  });
}
