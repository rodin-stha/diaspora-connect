import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/sizes.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/list_section.dart';
import '../../widgets/toggle_row.dart';
import 'data/notification_settings_provider.dart';
import 'models/notification_setting.dart';

/// Profile → Notification settings. Changes apply right away (no Save).
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    Widget section(String title, NotificationGroup group) => ListSection(
      title: title,
      titleGap: TSizes.xs,
      children: [
        for (final setting in NotificationSetting.values)
          if (setting.group == group)
            ToggleRow(
              title: _label(l10n, setting),
              value: settings[setting]!,
              onChanged: (on) => notifier.setEnabled(setting, on),
            ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            TSizes.pagePadding,
            topPadding,
            TSizes.pagePadding,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: TSizes.groupGap,
            children: [
              BackTitleBar(
                title: l10n.notificationSettings,
                fallbackLocation: '/profile',
              ),
              section(l10n.howNotifiedSection, NotificationGroup.channel),
              section(l10n.whatNotifiedSection, NotificationGroup.topic),
            ],
          ),
        ),
      ),
    );
  }

  static String _label(AppLocalizations l10n, NotificationSetting setting) =>
      switch (setting) {
        NotificationSetting.smsAlerts => l10n.notifySms,
        NotificationSetting.inAppAlerts => l10n.notifyInApp,
        NotificationSetting.issueStatusChanges => l10n.notifyIssueStatus,
        NotificationSetting.documentExpiryReminders =>
          l10n.notifyDocumentExpiry,
        NotificationSetting.embassyAnnouncements => l10n.notifyAnnouncements,
      };
}
