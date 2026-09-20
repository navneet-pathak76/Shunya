import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/sunya_notification_service.dart';
import '../../core/notifications/sunya_reminder_preferences.dart';
import '../../core/widgets/sunya_glass.dart';

class ReminderSettingsPage extends ConsumerWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sunyaReminderSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load reminders: $error')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('SUNYA reminders', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            const Text('Keep reminders local and purposeful. You control every reminder.'),
            const SizedBox(height: 20),
            SunyaGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily appearance check-in'),
                    subtitle: Text(
                      'Every day at ${_formatTime(settings.appearanceHour, settings.appearanceMinute)',
                    ),
                    value: settings.appearanceEnabled,
                    onChanged: (enabled) => _setAppearance(
                      context, ref, enabled: enabled,
                      hour: settings.appearanceHour,
                      minute: settings.appearanceMinute,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder time'),
                    subtitle: const Text('Choose when SUNYA should prompt you.'),
                    trailing: Text(${_formatTime(settings.appearanceHour, settings.appearanceMinute)),
                    enabled: settings.appearanceEnabled,
                    onTap: settings.appearanceEnabled
                        ? () => _pickTime(context, ref, settings)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SunyaGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notification behavior',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text(
                    'Native Android/iOS builds can schedule the daily reminder. '
                    'Browsers cannot reliably schedule repeating notifications, '
                    'so web keeps the same settings without pretending it can schedule them.',
                  ),
                  const SizedBox(height: 14),
                  FilledButton.tonal(
                    onPressed: () async {
                      final granted =
                          await SunyaNotificationService.instance.requestPermission();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(granted
                              ? 'Notification permission ready.'
                              : 'Notification permission was not granted.'),
                        ),
                      );
                    },
                    child: const Text('Allow notifications'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(int hour, int minute) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return h.toString() + ':' + minute.toString().padLeft(2, '0') + ' ' + suffix;
  }

  Future<void> _setAppearance(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final service = SunyaNotificationService.instance;
    if (enabled) {
      final granted = await service.requestPermission();
      if (!granted) return;
      await service.scheduleDailyAppearance(hour: hour, minute: minute);
    } else {
      await service.cancelAppearanceReminder();
    }
    await ref.read(sunyaReminderSettingsProvider.notifier).save(
          SunyaReminderPreferences(
            appearanceEnabled: enabled,
            appearanceHour: hour,
            appearanceMinute: minute,
          ),
        );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    SunyaReminderPreferences settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.appearanceHour,
        minute: settings.appearanceMinute,
      ),
    );
    if (picked == null) return;
    await SunyaNotificationService.instance.scheduleDailyAppearance(
      hour: picked.hour,
      minute: picked.minute,
    );
    await ref.read(sunyaReminderSettingsProvider.notifier).save(
          SunyaReminderPreferences(
            appearanceEnabled: true,
            appearanceHour: picked.hour,
            appearanceMinute: picked.minute,
          ),
        );
  }
}
