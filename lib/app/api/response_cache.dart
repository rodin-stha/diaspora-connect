import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locale_provider.dart';

final responseCacheProvider = Provider<ResponseCache>(
  (ref) => ResponseCache(ref.read(sharedPreferencesProvider)),
);

/// GET responses saved on the device as raw JSON, keyed by language and URL,
/// so screens can show the last content while offline. Cleared on sign-out.
class ResponseCache {
  ResponseCache(this._prefs);
  final SharedPreferences _prefs;

  static const _prefix = 'cache:';

  Future<void> write(String key, Object? data) =>
      _prefs.setString('$_prefix$key', jsonEncode(data));

  Object? read(String key) {
    final saved = _prefs.getString('$_prefix$key');

    return saved == null ? null : jsonDecode(saved);
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys.toList()) {
      await _prefs.remove(key);
    }
  }
}
