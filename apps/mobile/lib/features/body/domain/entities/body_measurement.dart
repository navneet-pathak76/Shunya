class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    required this.bodyFatPercent,
    this.notes = '',
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double bodyFatPercent;
  final String notes;

  double get bmi {
    if (heightCm <= 0) return 0;
    final metres = heightCm / 100;
    return weightKg / (metres * metres);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toUtc().toIso8601String(),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'bodyFatPercent': bodyFatPercent,
        'notes': notes,
      };

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] as String? ?? DateTime.now().toUtc().toIso8601String();
    return BodyMeasurement(
      id: json['id'] as String? ?? '',
      date: DateTime.parse(rawDate).toUtc(),
      weightKg: (json['weightKg'] as num? ?? 0).toDouble(),
      heightCm: (json['heightCm'] as num? ?? 0).toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num? ?? 0).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
