import 'package:diaspora_connect/features/issues/models/issue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Issue.fromJson reads a real GET /issues entry', () {
    // Copied from the API (2026-10-07).
    final issue = Issue.fromJson({
      'id': 52,
      'issue_category': {'id': 4, 'name': 'Education'},
      'employer': 'Rodin Test',
      'subject': 'Notification test',
      'description': 'Test',
      'evidence_photo': null,
      'location': null,
      'recording': null,
      'status': {'value': 'assigned', 'label': 'Assigned'},
      'assigned_to': {'id': 1, 'name': 'Super Admin'},
      'assigned_at': '2026-10-07T04:01:52+00:00',
      'unread_updates_count': 2,
      'created_at': '2026-10-07T04:01:09+00:00',
    });

    expect(issue.reference, '52');
    expect(issue.title, 'Notification test');
    expect(issue.category.name, 'Education');
    expect(issue.concerned, 'Rodin Test');
    expect(issue.status, IssueStatus.assigned);
    expect(issue.assignedTo, 'Super Admin');
    expect(issue.history, isEmpty); // the list has no history
  });

  test('Issue.fromJson handles an unassigned issue', () {
    final issue = Issue.fromJson({
      'id': 53,
      'subject': 'New one',
      'status': {'value': 'new', 'label': 'New'},
      'assigned_to': null,
      'assigned_at': null,
      'created_at': '2026-10-07T04:01:09+00:00',
    });

    expect(issue.status, IssueStatus.submitted);
    expect(issue.assignedTo, isNull);
  });

  test('Issue.fromJson reads the needs_info status', () {
    final issue = Issue.fromJson({
      'id': 52,
      'subject': 'Notification test',
      'status': {'value': 'needs_info', 'label': 'Needs Info'},
      'created_at': '2026-10-07T04:01:09+00:00',
    });

    expect(issue.status, IssueStatus.needsInfo);
  });

  test('Issue.fromJson reads status_history from GET /issues/{id}', () {
    Map<String, dynamic> change(String? from, String to, String at) => {
      'from_status': from == null ? null : {'value': from, 'label': from},
      'to_status': {'value': to, 'label': to},
      'changed_by': {'id': 1, 'name': 'Super Admin'},
      'changed_at': at,
    };

    // Shortened from the real response (2026-10-07).
    final issue = Issue.fromJson({
      'id': 52,
      'subject': 'Notification test',
      'status': {'value': 'resolved', 'label': 'Resolved'},
      'status_history': [
        change(null, 'new', '2026-10-07T04:01:09+00:00'),
        change('new', 'assigned', '2026-10-07T04:01:51+00:00'),
        change('assigned', 'resolved', '2026-10-07T04:08:53+00:00'),
        change('resolved', 'in_progress', '2026-10-07T04:11:00+00:00'),
        change('in_progress', 'resolved', '2026-10-07T04:11:20+00:00'),
      ],
      'created_at': '2026-10-07T04:01:09+00:00',
    });

    expect(issue.history.map((change) => change.status), [
      IssueStatus.submitted,
      IssueStatus.assigned,
      IssueStatus.resolved,
      IssueStatus.inProgress,
      IssueStatus.resolved,
    ]);
    expect(
      issue.history.last.date,
      DateTime.utc(2026, 10, 7, 4, 11, 20).toLocal(),
    );
  });

  test('Issue.fromJson reads the message sent with a status change', () {
    // Shortened from the real GET /issues/52 response (2026-10-13).
    final issue = Issue.fromJson({
      'id': 52,
      'subject': 'Notification test',
      'status': {'value': 'needs_info', 'label': 'Needs Info'},
      'status_history': [
        {
          'from_status': null,
          'to_status': {'value': 'new', 'label': 'New'},
          'changed_by': {'id': 9, 'name': 'Rodin Shrestha'},
          'body': null,
          'changed_at': '2026-10-07T04:01:09+00:00',
        },
        {
          'from_status': {'value': 'in_progress', 'label': 'In Progress'},
          'to_status': {'value': 'needs_info', 'label': 'Needs Info'},
          'changed_by': {'id': 1, 'name': 'Super Admin'},
          'body':
              'Please add your photograph, the current one is not clearly '
              'visible!',
          'changed_at': '2026-10-13T08:05:42+00:00',
        },
      ],
      'created_at': '2026-10-07T04:01:09+00:00',
    });

    expect(issue.history.first.body, isNull);
    expect(issue.history.last.status, IssueStatus.needsInfo);
    expect(
      issue.history.last.body,
      'Please add your photograph, the current one is not clearly visible!',
    );
  });

  test('Issue.fromJson reads the answer to a status change', () {
    // Shortened from the real GET /issues/52 response (2026-10-13).
    Map<String, dynamic> needsInfo(Map<String, dynamic>? answer) => {
      'to_status': {'value': 'needs_info', 'label': 'Needs Info'},
      'body': 'add some image',
      'answer': answer,
      'changed_at': '2026-10-13T08:40:31+00:00',
    };

    final issue = Issue.fromJson({
      'id': 52,
      'subject': 'Notification test',
      'status': {'value': 'in_progress', 'label': 'In Progress'},
      'status_history': [
        needsInfo(null),
        needsInfo({
          'body': 'Test',
          'attachment': null,
          'answered_at': '2026-10-13T08:39:21+00:00',
        }),
        needsInfo({
          'body': 'Assassin',
          'attachment': {
            'id': 56,
            'type': {'value': 'issue_reply', 'label': 'Reply Attachment'},
            'name': 'Reply Attachment',
            'file_name': 'image_picker_55A13626.jpg',
            'mime_type': 'image/jpeg',
            'size': 1248217,
            'url': 'https://diaspora.kumo-labs.com/storage/56/a.jpg?expires=1',
            'expires_at': '2026-10-13T09:17:36+00:00',
            'uploaded_at': '2026-10-13T08:41:02+00:00',
          },
          'answered_at': '2026-10-13T08:41:02+00:00',
        }),
      ],
      'created_at': '2026-10-07T04:01:09+00:00',
    });
    final [unanswered, textOnly, withPhoto] = issue.history;

    expect(unanswered.answer, isNull);
    expect(textOnly.answer!.body, 'Test');
    expect(textOnly.answer!.photoUrl, isNull);
    expect(withPhoto.answer!.body, 'Assassin');
    expect(
      withPhoto.answer!.photoUrl,
      'https://diaspora.kumo-labs.com/storage/56/a.jpg?expires=1',
    );
    expect(
      withPhoto.answer!.date,
      DateTime.utc(2026, 10, 13, 8, 41, 2).toLocal(),
    );
  });
}
