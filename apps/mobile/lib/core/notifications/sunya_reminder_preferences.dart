import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/local_record_repository.dart';
import '../providers/database_provider.dart';

class SunyaReminderPreferences {
  const SunyaReminderPreferences({
    this.appearanceEnabled = false,
    this.appearanceHour = 21,
    this.appearanceMinute = 0,
  });

  final bool appearanceEnabled;
  final int appearanceHour;
  final int appearanceMinute;

  Map<String, dynamic> toJson() => {
        'appearanceEnabled': appearanceEnabled,
        'appearanceHour': appearanceHour,
        'appearanceMinute': appearanceMinute,
      };

  factory SunyaReminderPreferences.fromJson(Map<String, dynamic> json) =>
      SunyaReminderPreferences(
        appearanceEnabled: json['appearanceEnabled'] as bool? ?? false,
        appearanceHour: json['appearanceHour'] as int? ?? 21,
        appearanceMinute: json['appearanceMinute'] as int? ?? 0,
      );
}

class SunyaReminderRepository {
  SunyaReminderRepository(this.local);
  final LocalRecordRepository local;

  static const domain = 'settings';
  static const key = 'reminders';

  Future<SunyaReminderPreferences> load() async {
    final record = await local.readPayload(domain, key);
    if (record == null) return const SunyaReminderPreferences();
    return SunyaReminderPreferences.fromJson(
      Map<String, dynamic>.from(record),
    );
  }

  Future<void> save(SunyaReminderPreferences value) => local.upsert(
        domain: domain,
        key: key,
        payload: value.toJson(),
      );
}

final sunyaReminderRepositoryProvider =
    FutureProvider<SunyaReminderRepository>(
  (ref) async => SunyaReminderRepository(
    await ref.watch(localRecordRepositoryProvider.future),
  ),
);

final sunyaReminderSettingsProvider = AsyncNotifierProvider<
    SunyaReminderSettingsController, SunyaReminderPreferences>(
  SunyaReminderSettingsController.new,
);

class SunyaReminderSettingsController
    extends AsyncNotifier<SunyaReminderPreferences> {
  @override
  Future<SunyaReminderPreferences> build() async {
    return ref.read(sunyaReminderRepositoryProvider.future).then((r) => r.load());
  }

  Future<void> save(SunyaReminderPreferences value) async {
    state = AsyncData(value);
    await ref.read(sunyaReminderRepositoryProvider.future).then(
          (repository) => repository.save(value),
        );
  }
}
