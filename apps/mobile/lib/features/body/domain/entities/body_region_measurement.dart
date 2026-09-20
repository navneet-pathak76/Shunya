enum BodyRegion {
  neck,
  shoulders,
  chest,
  waist,
  abdomen,
  hips,
  leftBiceps,
  rightBiceps,
  leftForearm,
  rightForearm,
  leftThigh,
  rightThigh,
  leftCalf,
  rightCalf,
}

extension BodyRegionLabel on BodyRegion {
  String get label {
    switch (this) {
      case BodyRegion.neck:
        return 'Neck';
      case BodyRegion.shoulders:
        return 'Shoulders';
      case BodyRegion.chest:
        return 'Chest';
      case BodyRegion.waist:
        return 'Waist';
      case BodyRegion.abdomen:
        return 'Abdomen';
      case BodyRegion.hips:
        return 'Hips';
      case BodyRegion.leftBiceps:
        return 'Left biceps';
      case BodyRegion.rightBiceps:
        return 'Right biceps';
      case BodyRegion.leftForearm:
        return 'Left forearm';
      case BodyRegion.rightForearm:
        return 'Right forearm';
      case BodyRegion.leftThigh:
        return 'Left thigh';
      case BodyRegion.rightThigh:
        return 'Right thigh';
      case BodyRegion.leftCalf:
        return 'Left calf';
      case BodyRegion.rightCalf:
        return 'Right calf';
    }
  }
}

class BodyRegionMeasurement {
  const BodyRegionMeasurement({
    required this.id,
    required this.region,
    required this.centimetres,
    required this.recordedAt,
    this.note = '',
  });

  final String id;
  final BodyRegion region;
  final double centimetres;
  final DateTime recordedAt;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'region': region.name,
        'centimetres': centimetres,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'note': note,
      };

  factory BodyRegionMeasurement.fromJson(Map<String, dynamic> json) {
    final region = BodyRegion.values.firstWhere(
      (value) => value.name == json['region'],
      orElse: () => BodyRegion.waist,
    );
    return BodyRegionMeasurement(
      id: json['id'] as String? ?? '',
      region: region,
      centimetres: (json['centimetres'] as num? ?? 0).toDouble(),
      recordedAt: DateTime.tryParse(json['recordedAt'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      note: json['note'] as String? ?? '',
    );
  }
}
