import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() once SharedPreferences has loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not set'),
);

const supportedAppLocales = [Locale('en'), Locale('ne')];

const _localeKey = 'app_locale';

/// The app's current language. Saved so it survives app restarts.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_localeKey);
    return supportedAppLocales.firstWhere(
      (locale) => locale.languageCode == saved,
      orElse: () => const Locale('en'),
    );
  }

  void setLocale(Locale locale) {
    state = locale;
    ref
        .read(sharedPreferencesProvider)
        .setString(_localeKey, locale.languageCode);
  }
}
