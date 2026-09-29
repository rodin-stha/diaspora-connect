import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/utils/validators.dart';

void main() {
  test('Israeli mobile accepts local and international formats', () {
    expect(TValidators.isIsraeliMobile('+972 52 123 4567'), isTrue);
    expect(TValidators.isIsraeliMobile('052-123-4567'), isTrue);
    expect(TValidators.isIsraeliMobile('+972 2 123 4567'), isFalse); // landline
    expect(TValidators.isIsraeliMobile('052123'), isFalse);
  });

  test('Nepali mobile accepts 96/97/98 numbers with or without +977', () {
    expect(TValidators.isNepaliMobile('+977 9812345678'), isTrue);
    expect(TValidators.isNepaliMobile('9712345678'), isTrue);
    expect(TValidators.isNepaliMobile('+977 01 4123456'), isFalse);
  });

  test('postal code is exactly 7 digits', () {
    expect(TValidators.isPostalCode('1234567'), isTrue);
    expect(TValidators.isPostalCode('123456'), isFalse);
    expect(TValidators.isPostalCode('12345a7'), isFalse);
  });

  test('email needs something@something.something', () {
    expect(TValidators.isEmail('sita@example.com'), isTrue);
    expect(TValidators.isEmail('sita@example'), isFalse);
    expect(TValidators.isEmail('sita example.com'), isFalse);
  });

  test('passport number is 6-9 letters or digits', () {
    expect(TValidators.isPassportNumber('09123456'), isTrue);
    expect(TValidators.isPassportNumber('pa 1234567'), isTrue);
    expect(TValidators.isPassportNumber('12345'), isFalse);
    expect(TValidators.isPassportNumber('09-123456'), isFalse);
  });
}
