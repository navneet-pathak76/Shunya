class HydrationEntry {
  const HydrationEntry({
    required this.id,
    required this.amountMl,
    required this.recordedAt,
    this.notes = '',
  });

  final String id;
  final int amountMl;
  final DateTime recordedAt;
  final String notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amountMl': amountMl,
        'recordedAt': recordedAt.toUtc().toIso8601String(),
        'notes': notes,
      };

  factory HydrationEntry.fromJson(Map<String, dynamic> json) {
    final rawDate = json['recordedAt'] as String? ?? DateTime.now().toUtc().toIso8601String();
    return HydrationEntry(
      id: json['id'] as String? ?? '',
      amountMl: (json['amountMl'] as num? ?? 0).toInt(),
      recordedAt: DateTime.parse(rawDate).toUtc(),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class HydrationSummary {
  const HydrationSummary({required this.targetMl, required this.entries});

  final int targetMl;
  final List<HydrationEntry> entries;

  int get totalConsumedMl => entries.fold(0, (sum, entry) => sum + entry.amountMl);
  double get progress => targetMl <= 0 ? 0 : (totalConsumedMl / targetMl).clamp(0.0, 1.0).toDouble();
  int get percentComplete => (progress * 100).round();
}
