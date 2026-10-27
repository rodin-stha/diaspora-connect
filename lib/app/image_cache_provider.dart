import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where network images are saved on the device, so they still show
/// offline. Tests replace it: the real one needs the phone's storage.
final imageCacheProvider = Provider<BaseCacheManager>(
  (ref) => DefaultCacheManager(),
);

/// The key an image is saved under: its link without the query string.
///
/// The API's image links expire after about an hour, so the same image
/// comes back with a new signature (`?X-Amz-Signature=…`) on each fetch.
/// Keyed by the full link, each fetch would download and save it again.
String imageCacheKey(String url) => url.split('?').first;
