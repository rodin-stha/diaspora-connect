import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/features/auth/data/auth_repository.dart';

void main() {
  test('normalizePhone strips spaces and dashes, and a leading 0', () {
    expect(normalizePhone('+972 52 123 4567'), '+972521234567');
    expect(normalizePhone('+972 052-123-4567'), '+972521234567');
    expect(normalizePhone('+972521234567'), '+972521234567');
  });
}
