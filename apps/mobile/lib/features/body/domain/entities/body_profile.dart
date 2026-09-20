enum BodyDataSource { manual, healthPlatform, wearable, imported }

class BodyProfile {
  const BodyProfile({
    required this.id,
    this.dateOfBirth,
    this.biologicalSex,
    this.heightCm,
    this.restingHeartRateBpm,
    this.systolicBp,
    this.diastolicBp,
    this.oxygenSaturationPercent,
    this.bodyTemperatureC,
    this.bodyFatPercent,
    this.muscleMassKg,
    this.bodyWaterPercent,
    this.boneMassKg,
    this.visceralFatLevel,
    this.bmrKcal,
    this.notes = '',
    this.source = BodyDataSource.manual,
    required this.updatedAt,
  });

  final String id;
  final DateTime? dateOfBirth;
  final String? biologicalSex;
  final double? heightCm;
  final double? restingHeartRateBpm;
  final double? systolicBp;
  final double? diastolicBp;
  final double? oxygenSaturationPercent;
  final double? bodyTemperatureC;
  final double? bodyFatPercent;
  final double? muscleMassKg;
  final double? bodyWaterPercent;
  final double? boneMassKg;
  final double? visceralFatLevel;
  final double? bmrKcal;
  final String notes;
  final BodyDataSource source;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateOfBirth': dateOfBirth?.toUtc().toIso8601String(),
        'biologicalSex': biologicalSex,
        'heightCm': heightCm,
        'restingHeartRateBpm': restingHeartRateBpm,
        'systolicBp': systolicBp,
        'diastolicBp': diastolicBp,
        'oxygenSaturationPercent': oxygenSaturationPercent,
        'bodyTemperatureC': bodyTemperatureC,
        'bodyFatPercent': bodyFatPercent,
        'muscleMassKg': muscleMassKg,
        'bodyWaterPercent': bodyWaterPercent,
        'boneMassKg': boneMassKg,
        'visceralFatLevel': visceralFatLevel,
        'bmrKcal': bmrKcal,
        'notes': notes,
        'source': source.name,
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory BodyProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) => value is String ? DateTime.tryParse(value)?.toUtc() : null;
    double? number(Object? value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

    return BodyProfile(
      id: json['id'] as String? ?? 'profile',
      dateOfBirth: parseDate(json['dateOfBirth']),
      biologicalSex: json['biologicalSex'] as String?,
      heightCm: number(json['heightCm']),
      restingHeartRateBpm: number(json['restingHeartRateBpm']),
      systolicBp: number(json['systolicBp']),
      diastolicBp: number(json['diastolicBp']),
      oxygenSaturationPercent: number(json['oxygenSaturationPercent']),
      bodyTemperatureC: number(json['bodyTemperatureC']),
      bodyFatPercent: number(json['bodyFatPercent']),
      muscleMassKg: number(json['muscleMassKg']),
      bodyWaterPercent: number(json['bodyWaterPercent']),
      boneMassKg: number(json['boneMassKg']),
      visceralFatLevel: number(json['visceralFatLevel']),
      bmrKcal: number(json['bmrKcal']),
      notes: json['notes'] as String? ?? '',
      source: BodyDataSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => BodyDataSource.manual,
      ),
      updatedAt: parseDate(json['updatedAt']) ?? DateTime.now().toUtc(),
    );
  }
}
