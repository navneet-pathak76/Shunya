class ReminderDefinition {
  const ReminderDefinition({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
}

abstract interface class NotificationService {
  Future<void> initialize();
  Future<void> schedule(ReminderDefinition reminder);
  Future<void> cancel(String reminderId);
}
