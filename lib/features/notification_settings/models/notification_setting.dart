/// Which section of the screen a setting belongs to.
enum NotificationGroup {
  /// How you're notified (SMS, in-app).
  channel,

  /// What you're notified about.
  topic,
}

/// Each on/off setting on the Notification settings screen, with its group
/// and what it starts as before the user changes it.
enum NotificationSetting {
  smsAlerts(NotificationGroup.channel, defaultOn: true),
  inAppAlerts(NotificationGroup.channel, defaultOn: true),
  issueStatusChanges(NotificationGroup.topic, defaultOn: true),
  documentExpiryReminders(NotificationGroup.topic, defaultOn: true),
  embassyAnnouncements(NotificationGroup.topic, defaultOn: false);

  final NotificationGroup group;
  final bool defaultOn;

  const NotificationSetting(this.group, {required this.defaultOn});
}
