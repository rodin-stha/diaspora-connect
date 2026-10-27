import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the image cache, which needs the phone's storage.
///
/// Every image fails to load at once, like an unreachable link, so screens
/// show their error widget and pumpAndSettle isn't left waiting on a
/// loading skeleton forever.
class FakeImageCache extends Fake implements BaseCacheManager {
  bool emptied = false;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => Stream.error(HttpExceptionWithStatus(404, 'Not in tests'));

  @override
  Future<void> emptyCache() async => emptied = true;
}
