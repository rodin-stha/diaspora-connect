import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env.dart';
import '../locale_provider.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Read at request time, not once here, so switching language
        // applies to the next request. Lets the API reply in Nepali.
        options.headers['Accept-Language'] = ref
            .read(localeProvider)
            .languageCode;
        handler.next(options);
      },
    ),
    if (kDebugMode)
      LogInterceptor(requestBody: true, responseBody: true, logPrint: _log),
  ]);

  ref.onDispose(dio.close);
  return dio;
});

void _log(Object line) => debugPrint('[api] $line');

/// Runs a Dio call and rethrows its failure as an [ApiException].
///
/// ```dart
/// final data = await apiCall(() => dio.post('/auth/login', data: {...}));
/// ```
Future<T> apiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
