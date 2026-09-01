import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/sunya_storage.dart';

final storageProvider = FutureProvider<SunyaStorage>((ref) async {
  return SunyaStorage.open();
});
