import 'package:diaspora_connect/features/in_app_alerts/models/issue_alert.dart';
import 'package:diaspora_connect/features/issues/models/issue.dart';
import 'package:flutter_test/flutter_test.dart';

Issue _issue(
  String reference, {
  IssueStatus status = IssueStatus.submitted,
  String? assignedTo,
}) => Issue(
  title: 'Unpaid salary',
  reference: reference,
  category: const IssueCategory(id: 1, name: 'Employment'),
  dueInDays: 5,
  status: status,
  assignedTo: assignedTo,
);

void main() {
  test('nothing changed: no alerts', () {
    final issues = [_issue('A')];
    expect(issueAlerts(issues, issues), isEmpty);
  });

  test('status change is reported', () {
    final alerts = issueAlerts(
      [_issue('A')],
      [_issue('A', status: IssueStatus.inProgress)],
    );
    expect(alerts, hasLength(1));
    final alert = alerts.single as IssueStatusChanged;
    expect(alert.reference, 'A');
    expect(alert.status, IssueStatus.inProgress);
  });

  test('newly assigned is reported', () {
    final alerts = issueAlerts(
      [_issue('A')],
      [_issue('A', assignedTo: 'Sita')],
    );
    expect((alerts.single as IssueAssigned).caseWorker, 'Sita');
  });

  test('status change and assignment together: one alert', () {
    final alerts = issueAlerts(
      [_issue('A')],
      [_issue('A', status: IssueStatus.inProgress, assignedTo: 'Sita')],
    );
    expect(alerts.single, isA<IssueStatusChanged>());
  });

  test('a new issue (reported by the user) is not an alert', () {
    expect(issueAlerts([_issue('A')], [_issue('B'), _issue('A')]), isEmpty);
  });
}
