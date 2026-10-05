import 'package:dio/dio.dart';

/// What went wrong with a request, in terms the UI can act on.
enum ApiErrorType {
  /// No internet, or the server couldn't be reached.
  noConnection,

  /// The server took too long to respond.
  timeout,

  /// The session is missing or expired (401). The user must sign in again.
  unauthorized,

  /// The server rejected the input (422), with a message per field.
  validation,

  /// The server rejected the request (other 4xx), e.g. a wrong code.
  badRequest,

  /// The server failed (5xx).
  server,

  unknown,
}

/// A failed request. Error bodies from the API look like:
///
/// ```json
/// {"success": false, "code": 422, "message": "Validation failed",
///  "data": {"phone": ["Enter a valid Nepali mobile number."]}}
/// ```
class ApiException implements Exception {
  final ApiErrorType type;
  final int? statusCode;

  /// The body's `message`, e.g. "Validation failed". The API replies in the
  /// app's language (we send Accept-Language), so 4xx messages can be shown.
  final String? serverMessage;

  /// The body's `data` when it holds messages per field, e.g.
  /// `{'phone': ['Enter a valid Nepali mobile number.']}`. Field names vary
  /// by endpoint, so nothing here is specific to one form.
  final Map<String, List<String>> fieldErrors;

  const ApiException(
    this.type, {
    this.statusCode,
    this.serverMessage,
    this.fieldErrors = const {},
  });

  factory ApiException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final type = switch (e.type) {
      DioExceptionType.connectionError => ApiErrorType.noConnection,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiErrorType.timeout,
      DioExceptionType.badResponse => switch (status) {
        401 => ApiErrorType.unauthorized,
        422 => ApiErrorType.validation,
        final s? when s >= 500 => ApiErrorType.server,
        _ => ApiErrorType.badRequest,
      },
      _ => ApiErrorType.unknown,
    };
    return ApiException(
      type,
      statusCode: status,
      serverMessage: _messageFrom(body),
      fieldErrors: _fieldErrorsFrom(body),
    );
  }

  /// True for 4xx: the server is talking about the user's request, so its
  /// message is meant for them. 5xx messages are internal details.
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// The first message for [field], to show under that form field.
  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;

  /// The first message for any field, when there's one place to show it
  /// (e.g. a snackbar).
  String? get firstFieldError =>
      fieldErrors.values.expand((messages) => messages).firstOrNull;

  static String? _messageFrom(Object? body) => switch (body) {
    {'message': final String message} when message.isNotEmpty => message,
    _ => null,
  };

  /// Reads `data` as `{field: [messages]}`. Also accepts a single string per
  /// field, and skips anything else, so a `data` that isn't field errors
  /// gives an empty map.
  static Map<String, List<String>> _fieldErrorsFrom(Object? body) {
    if (body case {'data': final Map<String, dynamic> data}) {
      return {
        for (final MapEntry(:key, :value) in data.entries)
          if (_messagesFrom(value) case final messages when messages.isNotEmpty)
            key: messages,
      };
    }
    return const {};
  }

  static List<String> _messagesFrom(Object? value) => switch (value) {
    final String message => [message],
    final List<dynamic> list => list.whereType<String>().toList(),
    _ => const [],
  };

  @override
  String toString() =>
      'ApiException($type, status: $statusCode, message: $serverMessage, '
      'fields: $fieldErrors)';
}
