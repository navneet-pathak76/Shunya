import 'package:isar/isar.dart';

part 'sunya_record.g.dart';

/// Generic local-first record used as the persistence boundary for SUNYA domains.
/// Domain repositories should wrap this type instead of exposing Isar directly.
@collection
class SunyaRecord {
  Id id = Isar.autoIncrement;

  late String domain;
  late String key;
  late String payload;
  DateTime? recordDate;
  late DateTime createdAt;
  late DateTime updatedAt;
  late int version;
  late bool deleted;
}
