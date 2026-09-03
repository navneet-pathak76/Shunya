import 'package:uuid/uuid.dart';

class SleepEntry {
  SleepEntry({
    String? id,
    required this.date,
    required this.bedtime,
    required this.waketime,
    this.quality = 0,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  final String id;
  final DateTime date;
  final DateTime bedtime;
  final DateTime waketime;
  final int quality;
  final String notes;

  Duration get duration => waketime.difference(bedtime);

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'bedtime': bedtime.toIso8601String(),
        'waketime': waketime.toIso8601String(),
        'quality': quality,
        'notes': notes,
      };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
        id: json['id'] as String?,
        date: DateTime.parse(json['date'] as String),
        bedtime: DateTime.parse(json['bedtime'] as String),
        waketime: DateTime.parse(json['waketime'] as String),
        quality: (json['quality'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}
