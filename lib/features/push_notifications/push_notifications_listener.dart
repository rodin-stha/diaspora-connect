import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import '../auth/data/auth_provider.dart';
import '../notification_settings/data/notification_settings_provider.dart';
import '../notification_settings/models/notification_setting.dart';
import 'push_token.dart';

/// Push notifications from Firebase Cloud Messaging. Android only for now:
/// iOS also needs an APNs key uploaded to Firebase.
///
/// What Android does depends on whether the app is open:
/// - closed or in the background: Android shows the notification itself;
///   tapping it opens the app, and [_open] goes to its `route`.
/// - on screen: Android shows nothing and hands the message to the app,
///   which shows it as a SnackBar (like [InAppAlertsListener]).
///
/// Messages may carry a `route` in their data (e.g. `/issues/GN-2083-004512`)
/// for the screen to open. Not agreed with the backend yet.
///
/// Starts once the user is signed in and onboarded, so the permission prompt
/// doesn't appear on the login screen. Wraps the whole app (MaterialApp's
/// `builder`).
class PushNotificationsListener extends ConsumerStatefulWidget {
  final Widget child;

  const PushNotificationsListener({super.key, required this.child});

  @override
  ConsumerState<PushNotificationsListener> createState() =>
      _PushNotificationsListenerState();
}

class _PushNotificationsListenerState
    extends ConsumerState<PushNotificationsListener> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(authProvider).isOnboarded) _start();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;
    final messaging = FirebaseMessaging.instance;

    // Android 13+ (and iOS) show nothing until the user allows it. Asks
    // only the first time; after that it returns the saved answer.
    await messaging.requestPermission();
    if (!mounted) return;

    _subscriptions.addAll([
      FirebaseMessaging.onMessage.listen(_showInApp),
      FirebaseMessaging.onMessageOpenedApp.listen(_open),
      // ignore: deprecated_member_use, see pushToken().
      messaging.onTokenRefresh.listen(_registerToken),
    ]);

    // The app was closed and the user opened it by tapping a notification.
    final initial = await messaging.getInitialMessage();
    if (initial != null && mounted) _open(initial);

    final token = await pushToken();
    if (token != null) _registerToken(token);
  }

  /// Sign-in sends the token to the server (`/register/verify-otp`). It can
  /// change later (app data cleared, Firebase rotating it), which is what
  /// `onTokenRefresh` reports.
  void _registerToken(String token) {
    // Debug builds only: paste it into Firebase Console → Messaging →
    // "Send test message".
    if (kDebugMode) debugPrint('[push] FCM token: $token');
    // TODO: send refreshed tokens to the backend once there's an endpoint;
    // until then the server keeps the one from sign-in.
  }

  String? _routeOf(RemoteMessage message) {
    final route = message.data['route'];
    // Only paths inside the app.
    return route is String && route.startsWith('/') ? route : null;
  }

  void _open(RemoteMessage message) {
    final route = _routeOf(message);
    if (route != null) ref.read(routerProvider).push(route);
  }

  void _showInApp(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null || !mounted) return;
    if (!ref.read(
      notificationSettingsProvider,
    )[NotificationSetting.inAppAlerts]!) {
      return;
    }

    final text = [
      notification.title,
      notification.body,
    ].whereType<String>().join('\n');
    if (text.isEmpty) return;

    final route = _routeOf(message);
    final router = ref.read(routerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        action: route == null
            ? null
            : SnackBarAction(
                label: AppLocalizations.of(context).viewAction,
                onPressed: () => router.push(route),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Signing in doesn't rebuild this widget from scratch (signing out
    // does), so start here when it happens.
    ref.listen(authProvider.select((auth) => auth.isOnboarded), (_, onboarded) {
      if (onboarded) _start();
    });
    return widget.child;
  }
}
