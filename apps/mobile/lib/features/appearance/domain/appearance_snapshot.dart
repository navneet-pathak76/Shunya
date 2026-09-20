enum AppearanceArea { face, hair, beard, underEyes, skin }

class AppearanceSnapshot {
  const AppearanceSnapshot({
    required this.id,
    required this.capturedAt,
    required this.imagePath,
    required this.area,
    this.imageDataBase64,
    this.notes = '',
    this.userScore,
    this.hairDensityScore,
    this.beardCoverageScore,
    this.underEyeScore,
    this.skinClarityScore,
    this.hairShedding,
    this.scalpItch,
    this.scalpFlaking,
    this.sleepHours,
  });

  final String id;
  final DateTime capturedAt;

  /// Legacy field retained for backwards compatibility. New captures store
  /// image bytes locally in [imageDataBase64] so Flutter Web never needs dart:io.
  final String imagePath;
  final String? imageDataBase64;
  final AppearanceArea area;
  final String notes;
  final double? userScore;
  final double? hairDensityScore;
  final double? beardCoverageScore;
  final double? underEyeScore;
  final double? skinClarityScore;
  final double? hairShedding;
  final bool? scalpItch;
  final bool? scalpFlaking;
  final double? sleepHours;

  Map<String, dynamic> toJson() => {
        'id': id,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        'imagePath': imagePath,
        'imageDataBase64': imageDataBase64,
        'area': area.name,
        'notes': notes,
        'userScore': userScore,
        'hairDensityScore': hairDensityScore,
        'beardCoverageScore': beardCoverageScore,
        'underEyeScore': underEyeScore,
        'skinClarityScore': skinClarityScore,
        'hairShedding': hairShedding,
        'scalpItch': scalpItch,
        'scalpFlaking': scalpFlaking,
        'sleepHours': sleepHours,
      };

  factory AppearanceSnapshot.fromJson(Map<String, dynamic> j) =>
      AppearanceSnapshot(
        id: j['id'] as String? ?? '',
        capturedAt: DateTime.tryParse(j['capturedAt'] as String? ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
        imagePath: j['imagePath'] as String? ?? '',
        imageDataBase64: j['imageDataBase64'] as String?,
        area: AppearanceArea.values.firstWhere(
          (x) => x.name == j['area'],
          orElse: () => AppearanceArea.face,
        ),
        notes: j['notes'] as String? ?? '',
        userScore: (j['userScore'] as num?)?.toDouble(),
        hairDensityScore: (j['hairDensityScore'] as num?)?.toDouble(),
        beardCoverageScore: (j['beardCoverageScore'] as num?)?.toDouble(),
        underEyeScore: (j['underEyeScore'] as num?)?.toDouble(),
        skinClarityScore: (j['skinClarityScore'] as num?)?.toDouble(),
        hairShedding: (j['hairShedding'] as num?)?.toDouble(),
        scalpItch: j['scalpItch'] as bool?,
        scalpFlaking: j['scalpFlaking'] as bool?,
        sleepHours: (j['sleepHours'] as num?)?.toDouble(),
      );
}
