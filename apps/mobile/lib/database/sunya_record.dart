/// Generic local-first record used as the persistence boundary for SUNYA domains.
/// Native builds persist this via Isar, while web builds persist it in browser
/// storage via the same JSON payload contract.
class SunyaRecord {
  SunyaRecord({
    this.id = 0,
    required this.domain,
    required this.key,
    required this.payload,
    this.recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.version = 0,
    this.deleted = false,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  final int id;
  final String domain;
  final String key;
  final String payload;
  final DateTime? recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final bool deleted;

  SunyaRecord copyWith({
    int? id,
    String? domain,
    String? key,
    String? payload,
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
    bool? deleted,
  }) {
    return SunyaRecord(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      key: key ?? this.key,
      payload: payload ?? this.payload,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'domain': domain,
        'key': key,
        'payload': payload,
        'recordDate': recordDate?.toUtc().toIso8601String(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'version': version,
        'deleted': deleted,
      };

  factory SunyaRecord.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    final created = json['createdAt'] as String? ?? now.toIso8601String();
    final updated = json['updatedAt'] as String? ?? now.toIso8601String();
    final recordDateRaw = json['recordDate'] as String?;

    return SunyaRecord(
      id: json['id'] as int? ?? 0,
      domain: json['domain'] as String? ?? '',
      key: json['key'] as String? ?? '',
      payload: json['payload'] as String? ?? '',
      recordDate: recordDateRaw == null ? null : DateTime.parse(recordDateRaw).toUtc(),
      createdAt: DateTime.parse(created).toUtc(),
      updatedAt: DateTime.parse(updated).toUtc(),
      version: json['version'] as int? ?? 0,
      deleted: json['deleted'] as bool? ?? false,
    );
  }
}
