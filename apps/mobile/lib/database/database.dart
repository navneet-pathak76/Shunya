import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'sunya_record.dart';

/// Owns the application's local Isar lifecycle.
///
/// Feature repositories should depend on this abstraction rather than opening
/// their own Isar instances. This keeps migrations, transactions and shutdown
/// behavior centralized.
class SunyaDatabase {
  SunyaDatabase._(this.isar);

  final Isar isar;

  static const _name = 'sunya';

  static Future<SunyaDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [SunyaRecordSchema],
      directory: directory.path,
      name: _name,
    );
    return SunyaDatabase._(isar);
  }

  IsarCollection<SunyaRecord> get records => isar.sunyaRecords;

  Future<void> close() => isar.close();

  Future<T> write<T>(Future<T> Function() operation) => isar.writeTxn(operation);
}
