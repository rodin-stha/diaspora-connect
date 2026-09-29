/// Format checks for form input. Pure functions, so they're easy to test;
/// forms turn a `false` into a translated error message.
class TValidators {
  TValidators._();

  /// Removes spaces, dashes and brackets people type in phone numbers.
  static String _digitsAndPlus(String value) =>
      value.replaceAll(RegExp(r'[\s\-()]'), '');

  /// Israeli mobile: 05X-XXX-XXXX, or +972 5X-XXX-XXXX.
  static bool isIsraeliMobile(String value) =>
      RegExp(r'^(\+972|972|0)5\d{8}$').hasMatch(_digitsAndPlus(value));

  /// Nepali mobile: 10 digits starting 96/97/98, optionally with +977.
  static bool isNepaliMobile(String value) =>
      RegExp(r'^(\+977|977)?9[678]\d{8}$').hasMatch(_digitsAndPlus(value));

  /// Israeli postal code: exactly 7 digits.
  static bool isPostalCode(String value) =>
      RegExp(r'^\d{7}$').hasMatch(value.trim());

  /// Basic shape check (something@something.something). The only real test
  /// of an email address is sending to it.
  static bool isEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());

  /// Passport number: 6–9 letters or digits (spaces ignored). Loose on
  /// purpose: Nepali passport formats have changed over the years.
  static bool isPassportNumber(String value) => RegExp(
    r'^[A-Z0-9]{6,9}$',
  ).hasMatch(value.replaceAll(' ', '').toUpperCase());
}
