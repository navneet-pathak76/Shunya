enum MeasurementType {
  weight,
  bodyFat,
  muscleMass,
  chest,
  waist,
  hip,
  arm,
  thigh,
  neck,
  custom,
}

class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.note,
  });

  final String id;
  final MeasurementType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? note;
}
