import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/auth_provider.dart';
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
        // The in-memory token, not the saved one: during onboarding it isn't
        // saved to the device yet, but those requests still need it.
        final token = ref.read(authProvider).token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // An expired or revoked token gets 401 on every request, so without
      // this the user would see errors everywhere until they found Sign
      // out. Signing out here makes the router send them to Login.
      onError: (error, handler) {
        final request = error.requestOptions;
        if (error.response?.statusCode == 401 &&
            // Only requests that sent a token: a 401 on Login means
            // something else (e.g. a wrong code), not an expired session.
            request.headers.containsKey('Authorization') &&
            // signOut already handles its own logout request failing.
            request.path != '/logout' &&
            // A late reply to a request from before the last sign-out.
            ref.mounted) {
          unawaited(ref.read(authProvider.notifier).endExpiredSession());
        }
        // Still passed on, so the screen that asked gets its error as usual.
        handler.next(error);
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
