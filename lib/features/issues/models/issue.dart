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

class Issue {
  final String title;
  final String reference;
  final IssueCategory category;

  /// Days until the deadline; negative when overdue.
  final int dueInDays;
  final IssueStatus status;

  /// Case worker handling the issue, or null if not assigned yet.
  final String? assignedTo;

  const Issue({
    required this.title,
    required this.reference,
    required this.category,
    required this.dueInDays,
    required this.status,
    this.assignedTo,
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
