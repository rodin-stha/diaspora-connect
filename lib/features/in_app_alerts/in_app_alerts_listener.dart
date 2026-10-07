import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import '../auth/data/auth_provider.dart';
import '../issues/data/issues_provider.dart';
import '../issues/models/issue.dart';
import '../notification_settings/data/notification_settings_provider.dart';
import '../notification_settings/models/notification_setting.dart';
import '../../widgets/status_pill.dart';
import 'models/issue_alert.dart';

/// How often to check for changes while the app is open.
const _pollInterval = Duration(minutes: 1);

/// Shows a message when a case worker changes one of the user's issues
/// (new status, assigned), while the app is open. Controlled by "In-app
/// alerts" and "Issue status changes" in Notification settings.
///
/// There's no push from the server yet, so it asks: every minute while the
/// app is in the foreground, and right away when the user returns to it.
/// Any fetch of the issues (also pull-to-refresh) is compared with the
/// previous one.
///
/// Wraps the whole app (MaterialApp's `builder`), so it runs on every
/// screen.
class InAppAlertsListener extends ConsumerStatefulWidget {
  final Widget child;

  const InAppAlertsListener({super.key, required this.child});

  @override
  ConsumerState<InAppAlertsListener> createState() =>
      _InAppAlertsListenerState();
}

class _InAppAlertsListenerState extends ConsumerState<InAppAlertsListener> {
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;

  /// The issues as of the last fetch; null until the first one. The first
  /// fetch only sets this: everything in it is already "seen".
  List<Issue>? _known;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      // Back in the app: check now, as the user may have been away a while.
      onResume: () {
        if (_alertsOn) _poll();
        _syncTimer();
      },
      onPause: _syncTimer,
    );
    _syncTimer();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _alertsOn {
    final settings = ref.read(notificationSettingsProvider);
    return ref.read(authProvider).isOnboarded &&
        settings[NotificationSetting.inAppAlerts]! &&
        settings[NotificationSetting.issueStatusChanges]!;
  }

  /// Polls only while alerts are on and the app is on screen: no requests
  /// (data, battery) from the background or for nothing.
  void _syncTimer() {
    final inForeground =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused;
    final shouldPoll = _alertsOn && inForeground;

    if (!shouldPoll) {
      _timer?.cancel();
      _timer = null;
    } else {
      _timer ??= Timer.periodic(_pollInterval, (_) => _poll());
    }
  }

  void _poll() => ref.read(issuesProvider.notifier).refreshQuietly();

  void _onIssues(List<Issue> issues) {
    final before = _known;
    _known = issues;
    if (before == null || !_alertsOn) return;

    final alerts = issueAlerts(before, issues);
    if (alerts.isEmpty) return;
    _show(alerts);
  }

  void _show(List<IssueAlert> alerts) {
    final l10n = AppLocalizations.of(context);
    final router = ref.read(routerProvider);

    // One change: say what it was and open that issue. Several: one
    // message for all, opening the list, instead of a queue of them.
    final (message, location) = switch (alerts) {
      [IssueStatusChanged(:final reference, :final title, :final status)] => (
        l10n.alertIssueStatusChanged(title, issueStatusLabel(l10n, status)),
        '/issues/$reference',
      ),
      [IssueAssigned(:final reference, :final title, :final caseWorker)] => (
        l10n.alertIssueAssigned(title, caseWorker),
        '/issues/$reference',
      ),
      _ => (l10n.alertIssuesUpdated(alerts.length), '/issues'),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: l10n.viewAction,
          onPressed: () => router.push(location),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Start or stop polling when the user signs in/out or flips a switch.
    ref.listen(authProvider, (_, auth) {
      // Signed out: forget the old account's issues.
      if (!auth.isOnboarded) _known = null;
      _syncTimer();
    });
    ref.listen(notificationSettingsProvider, (_, _) => _syncTimer());

    // Only when signed in: listening makes the provider fetch, and that
    // request would fail on the login screen.
    if (ref.watch(authProvider.select((auth) => auth.isOnboarded))) {
      ref.listen(issuesProvider, (_, next) {
        // Settled results only: not the loading state in between.
        if (next case AsyncData(:final value)) _onIssues(value);
      });
    }

    return widget.child;
  }
}
