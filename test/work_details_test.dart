import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/features/work_details/models/work_details.dart';

void main() {
  group('WorkDetails.fromJson', () {
    test('reads the API sample', () {
      final details = WorkDetails.fromJson({
        'id': 9,
        'employment_type': {
          'id': 5,
          'name': 'Restaurant & Catering',
          'allow_live_in_status': false,
        },
        'work_permit': {
          'id': 83,
          'type': {'value': 'work_permit', 'label': 'Work Permit'},
          'name': 'Work Permit',
          'file_name': 'image_picker_9357FF28.jpg',
          'mime_type': 'image/jpeg',
          'size': 951563,
          'url': 'https://diaspora.kumo-labs.com/storage/83/a.jpg?signature=x',
          'expires_at': '2026-10-15T04:45:25+00:00',
          'uploaded_at': '2026-10-15T04:12:49+00:00',
        },
        'live_in_situation': null,
        'employer_name': null,
      });

      expect(details.employmentTypeId, 5);
      expect(details.workPermitLetter, 'image_picker_9357FF28.jpg');
      // Nothing picked on this device yet.
      expect(details.workPermitFile, isNull);
      expect(details.careArrangement, isNull);
      expect(details.hostFamily, '');
    });

    test('reads live-in details', () {
      final details = WorkDetails.fromJson({
        'employment_type': {'id': 2},
        'work_permit': null,
        'live_in_situation': 'live_in',
        'employer_name': 'Cohen family',
      });

      expect(details.workPermitLetter, isNull);
      expect(details.careArrangement, CareArrangement.liveIn);
      expect(details.hostFamily, 'Cohen family');
    });

    test('an unknown live-in value counts as not chosen', () {
      final details = WorkDetails.fromJson({'live_in_situation': 'other'});
      expect(details.careArrangement, isNull);
    });
  });
}
