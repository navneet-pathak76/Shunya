enum AppearanceArea { face, hair, beard, underEyes, skin }

class AppearanceSnapshot {
  const AppearanceSnapshot({
    required this.id,
    required this.capturedAt,
    required this.imagePath,
    required this.area,
    this.notes = '',
    this.userScore,
    this.hairDensityScore,
    this.beardCoverageScore,
    this.underEyeScore,
    this.skinClarityScore,
  });

  final String id;
  final DateTime capturedAt;
  final String imagePath;
  final AppearanceArea area;
  final String notes;
  final double? userScore;
  final double? hairDensityScore;
  final double? beardCoverageScore;
  final double? underEyeScore;
  final double? skinClarityScore;

  Map<String,dynamic> toJson()=>{
    'id':id,'capturedAt':capturedAt.toUtc().toIso8601String(),
    'imagePath':imagePath,'area':area.name,'notes':notes,
    'userScore':userScore,'hairDensityScore':hairDensityScore,
    'beardCoverageScore':beardCoverageScore,'underEyeScore':underEyeScore,
    'skinClarityScore':skinClarityScore,
  };

  factory AppearanceSnapshot.fromJson(Map<String,dynamic> j)=>AppearanceSnapshot(
    id:j['id'] as String? ?? '',
    capturedAt:DateTime.tryParse(j['capturedAt'] as String? ?? '')?.toUtc() ?? DateTime.now().toUtc(),
    imagePath:j['imagePath'] as String? ?? '',
    area:AppearanceArea.values.firstWhere((x)=>x.name==j['area'],orElse:()=>AppearanceArea.face),
    notes:j['notes'] as String? ?? '',
    userScore:(j['userScore'] as num?)?.toDouble(),
    hairDensityScore:(j['hairDensityScore'] as num?)?.toDouble(),
    beardCoverageScore:(j['beardCoverageScore'] as num?)?.toDouble(),
    underEyeScore:(j['underEyeScore'] as num?)?.toDouble(),
    skinClarityScore:(j['skinClarityScore'] as num?)?.toDouble(),
  );
}