import 'issue_category.dart';

export 'issue_category.dart';

/// Lifecycle of an issue. Shown to users as "New", "In progress", etc.
enum IssueStatus {
  /// Just reported, nobody has picked it up yet. Shown as "New"
  /// (`new` is a reserved word in Dart).
  submitted,

  /// A case worker has taken it but not started yet.
  assigned,
  inProgress,
  escalated,
  resolved,

  /// Closed without a fix (the API's `rejected` or `failed`).
  rejected,
}

/// One change of an issue's status, from the API's `status_history`.
class StatusChange {
  final IssueStatus status;
  final DateTime date;

  const StatusChange(this.status, this.date);

  factory StatusChange.fromJson(Map<String, dynamic> json) => StatusChange(
    Issue.statusFromJson(json['to_status']),
    DateTime.parse(json['changed_at'] as String).toLocal(),
  );
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

  /// What the user wrote when reporting; may be empty.
  final String description;

  /// Employer or embassy the issue is about; may be empty.
  final String concerned;

  /// Every status the issue has had, oldest first. Only in the single-issue
  /// response (GET /issues/{id}); empty in the list.
  final List<StatusChange> history;

  const Issue({
    required this.title,
    required this.reference,
    required this.category,
    required this.dueInDays,
    required this.status,
    this.assignedTo,
    this.description = '',
    this.concerned = '',
    this.history = const [],
  });

  /// From one entry of `GET /issues`, or the single issue of
  /// `GET /issues/{id}` (which adds `status_history`).
  ///
  /// `status` and `assigned_to` are objects (`{value, label}` and
  /// `{id, name}`). There's no `reference` or `due_date` in the response
  /// yet, so the id stands in for the reference and the due date is 0.
  factory Issue.fromJson(Map<String, dynamic> json) {
    final dueDate = DateTime.tryParse(json['due_date'] as String? ?? '');
    final status = statusFromJson(json['status']);
    final category = json['issue_category'] ?? json['category'];

    return Issue(
      title: json['subject'] as String? ?? '',
      reference: (json['reference'] ?? json['id']).toString(),
      category: category is Map<String, dynamic>
          ? IssueCategory.fromJson(category)
          : const IssueCategory(id: 0, name: ''),
      dueInDays: dueDate == null
          ? 0
          : dueDate.difference(DateTime.now()).inDays,
      status: status,
      assignedTo:
          (json['assigned_to'] as Map<String, dynamic>?)?['name'] as String?,
      description: json['description'] as String? ?? '',
      concerned: json['employer'] as String? ?? '',
      history: [
        for (final change in json['status_history'] as List? ?? const [])
          StatusChange.fromJson(change as Map<String, dynamic>),
      ],
    );
  }

  /// A `{value, label}` status object. Unknown values count as new.
  static IssueStatus statusFromJson(Object? json) =>
      switch ((json as Map<String, dynamic>?)?['value']) {
        'assigned' => IssueStatus.assigned,
        'in_progress' => IssueStatus.inProgress,
        'escalated' => IssueStatus.escalated,
        'resolved' || 'closed' => IssueStatus.resolved,
        'rejected' || 'failed' => IssueStatus.rejected,
        _ => IssueStatus.submitted, // 'new'
      };

  /// When the issue reached its final status (resolved or rejected): the
  /// latest history entry. Null while it's open, or without history (the
  /// list response has none).
  DateTime? get completedAt => isOpen ? null : history.lastOrNull?.date;

  bool get isOverdue => dueInDays < 0;
  bool get isAssigned => assignedTo != null;
  bool get isOpen =>
      status != IssueStatus.resolved && status != IssueStatus.rejected;
}
