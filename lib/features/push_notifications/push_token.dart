import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// This device's FCM token: the address the server sends its pushes to.
/// Null if there's none (offline, no Google Play services) or it takes too
/// long, so callers like sign-in never fail or hang because of push.
///
/// Uses the deprecated getToken(): its replacement, register()/onRegistered,
/// gives an installation ID for FCM's new "direct send" instead of a token.
/// The backend expects a token (`fcm_token`), as do Firebase Console and the
/// usual server SDKs.
Future<String?> pushToken() async {
  try {
    // ignore: deprecated_member_use
    return await FirebaseMessaging.instance.getToken().timeout(
      const Duration(seconds: 5),
    );
  } on FirebaseException catch (e) {
    debugPrint('[push] no FCM token: ${e.message}');
  } on TimeoutException {
    debugPrint('[push] no FCM token: timed out');
  }
  return null;
}

/// The `platform` the backend stores with the token: it sends to Android
/// and iOS differently.
String get pushPlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
