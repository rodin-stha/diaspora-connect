import 'dart:async';

import 'package:dio/dio.dart';

import 'response_cache.dart';

/// Saves every GET response, and returns the saved copy when the device is
/// offline, so screens show the last content instead of an error.
class OfflineCacheInterceptor extends Interceptor {
  OfflineCacheInterceptor(this._cache);
  final ResponseCache _cache;

  // The language is part of the key: the API replies in English or Nepali.
  String _key(RequestOptions o) => '${o.headers['Accept-Language']}:${o.uri}';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    if (request.method == 'GET') {
      unawaited(_cache.write(_key(request), response.data));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    final isOffline =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;
    final cached = request.method == 'GET' && isOffline
        ? _cache.read(_key(request))
        : null;

    if (cached != null) {
      return handler.resolve(
        Response(requestOptions: request, data: cached, statusCode: 200),
      );
    }
    handler.next(err);
  }
}
