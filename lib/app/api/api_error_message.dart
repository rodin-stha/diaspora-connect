import '../../l10n/app_localizations.dart';
import 'api_exception.dart';

/// A user-facing message for a failed request, most specific first:
///
/// 1. The server's message for a field ("Enter a valid Nepali mobile number.")
/// 2. The server's general message, for 4xx only
/// 3. Our own translated message for the kind of error
///
/// Screens that show errors under each field can use
/// [ApiException.fieldError] instead.
String apiErrorMessage(AppLocalizations l10n, ApiException error) =>
    error.firstFieldError ??
    (error.isClientError ? error.serverMessage : null) ??
    switch (error.type) {
      ApiErrorType.noConnection => l10n.errorNoConnection,
      ApiErrorType.timeout => l10n.errorTimeout,
      _ => l10n.errorGeneric,
    };
