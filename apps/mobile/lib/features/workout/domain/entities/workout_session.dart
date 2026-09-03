import 'package:uuid/uuid.dart';

class WorkoutSet {
  WorkoutSet({
    String? id,
    required this.exerciseName,
    required this.repetitions,
    required this.weightKg,
    required this.completedAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String exerciseName;
  final int repetitions;
  final double weightKg;
  final DateTime completedAt;

  double get volumeKg => repetitions * weightKg;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseName': exerciseName,
        'repetitions': repetitions,
        'weightKg': weightKg,
        'completedAt': completedAt.toIso8601String(),
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        id: json['id'] as String?,
        exerciseName: json['exerciseName'] as String,
        repetitions: (json['repetitions'] as num).toInt(),
        weightKg: (json['weightKg'] as num).toDouble(),
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}

class WorkoutSession {
  WorkoutSession({
    String? id,
    required this.startedAt,
    this.endedAt,
    List<WorkoutSet>? sets,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [];

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<WorkoutSet> sets;
  final String notes;

  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);
  double get volumeKg => sets.fold(0, (sum, set) => sum + set.volumeKg);
  int get exerciseCount => sets.map((set) => set.exerciseName).toSet().length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'sets': sets.map((set) => set.toJson()).toList(),
        'notes': notes,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String?,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] == null ? null : DateTime.parse(json['endedAt'] as String),
        sets: (json['sets'] as List<dynamic>? ?? const [])
            .map((item) => WorkoutSet.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        notes: json['notes'] as String? ?? '',
      );
}
