import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/env.dart';
import 'app/locale_provider.dart';
import 'app/router.dart';
import 'app/session_provider_scope.dart';
import 'features/app_update/update_gate.dart';
import 'features/auth/data/token_storage.dart';
import 'features/connectivity/connectivity_listener.dart';
import 'features/in_app_alerts/in_app_alerts_listener.dart';
import 'features/push_notifications/push_notifications_listener.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'widgets/keyboard_done_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _reportCrashes();
  final prefs = await SharedPreferences.getInstance();
  final savedToken = await TokenStorage(const FlutterSecureStorage()).read();
  runApp(
    SessionProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      savedToken: savedToken,
      child: const MyApp(),
    ),
  );
}

/// Sends crashes to Firebase Crashlytics, from release builds only: in
/// debug they're in the console already, and would bury real users'
/// crashes in the dashboard.
Future<void> _reportCrashes() async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  // Errors in Flutter's own callbacks: building, layout, painting.
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  // Everything else, e.g. an exception in a Future nobody awaited.
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Diaspora Connect',
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => UpdateGate(
        child: InAppAlertsListener(
          child: PushNotificationsListener(
            child: ConnectivityListener(child: KeyboardDoneBar(child: child!)),
          ),
        ),
      ),
      locale: ref.watch(localeProvider),
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
