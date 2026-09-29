import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_provider.dart';
import '../models/notification_setting.dart';

/// Which notifications are on. Saved on the device so choices survive app
/// restarts (like the app language).
///
/// Once the backend exists it should own these (SMS is sent by the server);
/// then `setEnabled` would also call the API.
final notificationSettingsProvider =
    NotifierProvider<
      NotificationSettingsNotifier,
      Map<NotificationSetting, bool>
    >(
      NotificationSettingsNotifier.new,
    );

class NotificationSettingsNotifier
    extends Notifier<Map<NotificationSetting, bool>> {
  static String _key(NotificationSetting setting) => 'notify_${setting.name}';

  @override
  Map<NotificationSetting, bool> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return {
      for (final setting in NotificationSetting.values)
        setting: prefs.getBool(_key(setting)) ?? setting.defaultOn,
    };
  }

  void setEnabled(NotificationSetting setting, bool enabled) {
    // A new map, not `state[setting] = enabled`: Riverpod only notices a
    // change when `state` is a new object.
    state = {...state, setting: enabled};
    ref.read(sharedPreferencesProvider).setBool(_key(setting), enabled);
  }
}
