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
import 'features/auth/data/token_storage.dart';
import 'features/connectivity/connectivity_listener.dart';
import 'features/in_app_alerts/in_app_alerts_listener.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'widgets/keyboard_done_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  final prefs = await SharedPreferences.getInstance();
  final savedToken = await TokenStorage(const FlutterSecureStorage()).read();
  // Debug builds only: copy it into Postman/curl to call the API by hand.
  // TODO: remove once the Saved documents endpoints are wired up.
  if (kDebugMode) debugPrint('[auth] token: $savedToken');
  runApp(
    SessionProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      savedToken: savedToken,
      child: const MyApp(),
    ),
  );
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
      // Wraps every screen, so alerts, the offline message and the keyboard's
      // Done bar show wherever the user is.
      builder: (context, child) => InAppAlertsListener(
        child: ConnectivityListener(child: KeyboardDoneBar(child: child!)),
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
