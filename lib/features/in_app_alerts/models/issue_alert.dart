import '../../issues/models/issue.dart';

/// Something a case worker changed on one of the user's issues, worth
/// telling them about while the app is open.
sealed class IssueAlert {
  /// Opens the issue (its route) when the alert is tapped.
  final String reference;

  /// What the user called the issue: shown in the alert, since they'll
  /// recognise it (the reference is just a number to them).
  final String title;

  const IssueAlert(this.reference, this.title);
}

class IssueStatusChanged extends IssueAlert {
  final IssueStatus status;

  const IssueStatusChanged(super.reference, super.title, this.status);
}

class IssueAssigned extends IssueAlert {
  final String caseWorker;

  const IssueAssigned(super.reference, super.title, this.caseWorker);
}

/// What changed between two fetches of the issue list.
///
/// Only issues in both lists count: a new issue is one the user just
/// reported themselves, nothing to alert about. A pure function (no
/// providers, no widgets), so it's easy to test.
List<IssueAlert> issueAlerts(List<Issue> before, List<Issue> after) {
  final previous = {for (final issue in before) issue.reference: issue};

  return [
    for (final issue in after)
      if (previous[issue.reference] case final old?) ...[
        if (issue.status != old.status)
          IssueStatusChanged(issue.reference, issue.title, issue.status)
        // A status change already says something happened; don't also
        // report the assignment that usually comes with it.
        else if (old.assignedTo == null && issue.assignedTo != null)
          IssueAssigned(issue.reference, issue.title, issue.assignedTo!),
      ],
  ];
}
