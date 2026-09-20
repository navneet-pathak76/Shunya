import 'package:isar/isar.dart';

part 'sunya_record_native.g.dart';

@collection
class SunyaRecordNative {
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
