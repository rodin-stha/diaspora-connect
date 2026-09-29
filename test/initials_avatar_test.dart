import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/widgets/initials_avatar.dart';

void main() {
  group('InitialsAvatar.initialsOf', () {
    test('uses the first and last names, skipping middle names', () {
      expect(InitialsAvatar.initialsOf('Sita Kumari Shrestha'), 'SS');
    });

    test('single name gives one letter', () {
      expect(InitialsAvatar.initialsOf('Sita'), 'S');
    });

    test('ignores extra spaces and upper-cases', () {
      expect(InitialsAvatar.initialsOf('  sita   shrestha '), 'SS');
    });

    test('empty name gives nothing', () {
      expect(InitialsAvatar.initialsOf('   '), '');
    });

    test('keeps whole Devanagari characters', () {
      // "सी" is two code units (स + ी) and "श्रे" is four (a conjunct);
      // each is one visible character. name[0] would return only स.
      expect(InitialsAvatar.initialsOf('सीता श्रेष्ठ'), 'सीश्रे');
    });
  });
}
