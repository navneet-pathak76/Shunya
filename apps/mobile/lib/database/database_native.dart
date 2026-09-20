import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'sunya_record.dart';
import 'sunya_record_native.dart';

/// Native persistence implementation using Isar.
class SunyaDatabase {
  SunyaDatabase._(this.isar);

  final Isar isar;

  static const _name = 'sunya';

  static Future<SunyaDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [SunyaRecordNativeSchema],
      directory: directory.path,
      name: _name,
    );
    return SunyaDatabase._(isar);
  }

  IsarCollection<SunyaRecordNative> get records => isar.sunyaRecordNatives;

  Future<void> close() => isar.close();

  Future<T> write<T>(Future<T> Function() operation) => isar.writeTxn(operation);

  Future<List<SunyaRecord>> listAll() async {
    final items = await records.where().findAll();
    return items.map(_fromNative).toList(growable: false);
  }

  Future<void> put(SunyaRecord record) async {
    await write(() async {
      final item = _toNative(record);
      await records.put(item);
    });
  }

  static SunyaRecord _fromNative(SunyaRecordNative item) {
    return SunyaRecord(
      id: item.id,
      domain: item.domain,
      key: item.key,
      payload: item.payload,
      recordDate: item.recordDate,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      version: item.version,
      deleted: item.deleted,
    );
  }

  static SunyaRecordNative _toNative(SunyaRecord record) {
    final item = SunyaRecordNative()
      ..id = record.id
      ..domain = record.domain
      ..key = record.key
      ..payload = record.payload
      ..recordDate = record.recordDate
      ..createdAt = record.createdAt
      ..updatedAt = record.updatedAt
      ..version = record.version
      ..deleted = record.deleted;
    return item;
  }
}
