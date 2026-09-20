enum BodyGoalType { targetWeight, targetBodyFat, targetMeasurement }

class BodyGoal {
  const BodyGoal({
    required this.id,
    required this.type,
    required this.label,
    required this.targetValue,
    this.region,
    this.unit = '',
    this.deadline,
    this.active = true,
    required this.createdAt,
  });

  final String id;
  final BodyGoalType type;
  final String label;
  final double targetValue;
  final String? region;
  final String unit;
  final DateTime? deadline;
  final bool active;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id, 'type': type.name, 'label': label,
        'targetValue': targetValue, 'region': region, 'unit': unit,
        'deadline': deadline?.toUtc().toIso8601String(),
        'active': active, 'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory BodyGoal.fromJson(Map<String, dynamic> json) {
    final type = BodyGoalType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => BodyGoalType.targetWeight,
    );
    return BodyGoal(
      id: json['id'] as String? ?? '',
      type: type,
      label: json['label'] as String? ?? 'Body goal',
      targetValue: (json['targetValue'] as num? ?? 0).toDouble(),
      region: json['region'] as String?,
      unit: json['unit'] as String? ?? '',
      deadline: DateTime.tryParse(json['deadline'] as String? ?? '')?.toUtc(),
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
    );
  }
}
