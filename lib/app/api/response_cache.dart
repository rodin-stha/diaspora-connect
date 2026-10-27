import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../image_cache_provider.dart';
import '../locale_provider.dart';

final responseCacheProvider = Provider<ResponseCache>(
  (ref) => ResponseCache(
    ref.read(sharedPreferencesProvider),
    ref.read(imageCacheProvider),
  ),
);

/// GET responses saved on the device as raw JSON, keyed by language and URL,
/// so screens can show the last content while offline. Cleared on sign-out.
///
/// Images are saved separately, by CachedNetworkImage, but cleared here
/// too: they're the user's data as much as the JSON is.
class ResponseCache {
  ResponseCache(this._prefs, this._images);
  final SharedPreferences _prefs;
  final BaseCacheManager _images;

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
    await _images.emptyCache();
  }
}
