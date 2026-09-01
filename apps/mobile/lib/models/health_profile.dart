enum BiologicalSex { male, female, intersex, undisclosed }

enum GoalDirection { increase, decrease, maintain, improve }

class HealthProfile {
  const HealthProfile({
    required this.id,
    this.displayName,
    this.dateOfBirth,
    this.biologicalSex,
    this.heightCm,
    this.baselineWeightKg,
  });

  final String id;
  final String? displayName;
  final DateTime? dateOfBirth;
  final BiologicalSex? biologicalSex;
  final double? heightCm;
  final double? baselineWeightKg;
}
