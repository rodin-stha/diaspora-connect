/// Lifecycle of an issue. Shown to users as "New", "In progress", etc.
enum IssueStatus {
  /// Just reported, nobody has picked it up yet. Shown as "New"
  /// (`new` is a reserved word in Dart).
  submitted,
  inProgress,
  escalated,
  resolved,
}

enum IssueCategory { wages, permit, housing, documents }

/// A step on an issue's timeline ("Submitted", "Escalated to…").
enum IssueEventType {
  submitted,
  assignedToEmployer,
  escalatedToEmbassy,
  resolved,
}

class IssueEvent {
  final IssueEventType type;

  /// When the step happened, or null if it hasn't happened yet.
  final DateTime? date;

  const IssueEvent(this.type, [this.date]);

  bool get isDone => date != null;
}

class Issue {
  final String title;
  final String reference;
  final IssueCategory category;

  /// Days until the deadline; negative when overdue.
  final int dueInDays;
  final IssueStatus status;

  /// Case worker handling the issue, or null if not assigned yet.
  final String? assignedTo;

  /// Steps in order: completed ones first, then upcoming ones.
  final List<IssueEvent> timeline;

  const Issue({
    required this.title,
    required this.reference,
    required this.category,
    required this.dueInDays,
    required this.status,
    this.assignedTo,
    this.timeline = const [],
  });

  bool get isOverdue => dueInDays < 0;
  bool get isAssigned => assignedTo != null;
  bool get isOpen => status != IssueStatus.resolved;

  /// Case-insensitive match on the reference number or title.
  bool matchesSearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return reference.toLowerCase().contains(q) ||
        title.toLowerCase().contains(q);
  }
}
