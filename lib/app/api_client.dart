import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Read at build time from `--dart-define-from-file=env.json` (see
/// env.example.json). Not secret-proof: anything compiled into the app can
/// be extracted from it, so this is for development only.
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://diaspora.kumo-labs.com/api/v1',
);

/// TEMPORARY, until login uses the real OTP API: a token copied from
/// Postman. Then the token will come from [authProvider] instead.
const _token = String.fromEnvironment('API_TOKEN');

/// The one HTTP client for the backend. Every feature's API class gets it
/// from here, so base URL, auth and timeouts are set in one place.
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // Without this Laravel answers auth errors with an HTML redirect
      // instead of a JSON 401.
      headers: {'Accept': 'application/json'},
    ),
  );
  // Runs before every request, like an axios request interceptor.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});
