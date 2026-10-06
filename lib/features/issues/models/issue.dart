import 'issue_category.dart';

export 'issue_category.dart';

/// Lifecycle of an issue. Shown to users as "New", "In progress", etc.
enum IssueStatus {
  /// Just reported, nobody has picked it up yet. Shown as "New"
  /// (`new` is a reserved word in Dart).
  submitted,
  inProgress,
  escalated,
  resolved,
}

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

  /// What the user wrote when reporting; may be empty.
  final String description;

  /// Employer or embassy the issue is about; may be empty.
  final String concerned;

  /// Steps in order: completed ones first, then upcoming ones.
  final List<IssueEvent> timeline;

  const Issue({
    required this.title,
    required this.reference,
    required this.category,
    required this.dueInDays,
    required this.status,
    this.assignedTo,
    this.description = '',
    this.concerned = '',
    this.timeline = const [],
  });

  /// From one entry of `GET /issues`.
  ///
  /// TODO: the keys below are a best guess (no issues existed yet to see a
  /// real response). Check them against the first real issue, especially
  /// reference, status, due date and the timeline.
  factory Issue.fromJson(Map<String, dynamic> json) {
    final dueDate = DateTime.tryParse(json['due_date'] as String? ?? '');
    final createdAt = DateTime.tryParse(
      json['created_at'] as String? ?? '',
    )?.toLocal();
    final status = switch (json['status']) {
      'in_progress' => IssueStatus.inProgress,
      'escalated' => IssueStatus.escalated,
      'resolved' || 'closed' => IssueStatus.resolved,
      _ => IssueStatus.submitted,
    };
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
      assignedTo: json['assigned_to'] as String?,
      description: json['description'] as String? ?? '',
      concerned: json['employer'] as String? ?? '',
      timeline: _timelineFrom(status, createdAt),
    );
  }

  /// The steps shown on Track issue, built from the status and creation date
  /// until the API's own history is mapped. Steps without a date show as
  /// upcoming (grey).
  static List<IssueEvent> _timelineFrom(
    IssueStatus status,
    DateTime? createdAt,
  ) => [
    IssueEvent(IssueEventType.submitted, createdAt),
    const IssueEvent(IssueEventType.assignedToEmployer),
    if (status == IssueStatus.escalated)
      const IssueEvent(IssueEventType.escalatedToEmbassy),
    const IssueEvent(IssueEventType.resolved),
  ];

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
