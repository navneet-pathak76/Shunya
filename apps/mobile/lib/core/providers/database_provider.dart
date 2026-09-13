import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

final sunyaDatabaseProvider = FutureProvider<SunyaDatabase>((ref) async {
  final database = await SunyaDatabase.open();
  ref.onDispose(database.close);
  return database;
});
