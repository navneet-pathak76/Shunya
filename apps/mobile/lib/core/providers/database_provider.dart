import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../database/local_record_repository.dart';

final sunyaDatabaseProvider = FutureProvider<SunyaDatabase>((ref) async {
  final database = await SunyaDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final localRecordRepositoryProvider = FutureProvider<LocalRecordRepository>((ref) async {
  final database = await ref.watch(sunyaDatabaseProvider.future);
  return LocalRecordRepository(database);
});
