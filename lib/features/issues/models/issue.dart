enum IssueStatus { inProgress, escalated }

class Issue {
  final String title;
  final String reference;

  /// Days until the deadline; negative when overdue.
  final int dueInDays;
  final IssueStatus status;

  const Issue({
    required this.title,
    required this.reference,
    required this.dueInDays,
    required this.status,
  });

  bool get isOverdue => dueInDays < 0;
}
