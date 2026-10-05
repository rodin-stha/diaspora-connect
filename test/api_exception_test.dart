import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/app/api/api_error_message.dart';
import 'package:diaspora_connect/app/api/api_exception.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';

/// A failed response with [status] and [body], as Dio reports it.
ApiException failed(int status, Object? body) {
  final options = RequestOptions(path: '/register');
  return ApiException.fromDio(
    DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: options,
        statusCode: status,
        data: body,
      ),
    ),
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('422: reads field errors, whatever the field is called', () {
    final error = failed(422, {
      'success': false,
      'code': 422,
      'message': 'Validation failed',
      'data': {
        'phone': ['Enter a valid Nepali mobile number.'],
      },
    });

    expect(error.type, ApiErrorType.validation);
    expect(error.serverMessage, 'Validation failed');
    expect(error.fieldError('phone'), 'Enter a valid Nepali mobile number.');
    expect(error.fieldError('email'), isNull);
    expect(
      apiErrorMessage(l10n, error),
      'Enter a valid Nepali mobile number.',
    );
  });

  test('accepts a single string per field and skips non-messages', () {
    final error = failed(422, {
      'data': {'otp': 'Code expired.', 'retry_after': 30},
    });

    expect(error.fieldErrors, {
      'otp': ['Code expired.'],
    });
  });

  test('4xx without field errors shows the server message', () {
    final error = failed(400, {'message': 'Too many attempts.'});

    expect(error.type, ApiErrorType.badRequest);
    expect(apiErrorMessage(l10n, error), 'Too many attempts.');
  });

  test('5xx never shows the server message', () {
    final error = failed(500, {'message': 'SQLSTATE[23000]: ...'});

    expect(error.type, ApiErrorType.server);
    expect(apiErrorMessage(l10n, error), l10n.errorGeneric);
  });

  test('a body that is not JSON falls back to the generic message', () {
    final error = failed(502, '<html>Bad Gateway</html>');

    expect(error.fieldErrors, isEmpty);
    expect(apiErrorMessage(l10n, error), l10n.errorGeneric);
  });
}
