/// Lifecycle of an issue. Shown to users as "New", "In progress", etc.
enum IssueStatus {
  /// Just reported, nobody has picked it up yet. Shown as "New"
  /// (`new` is a reserved word in Dart).
  submitted,
  inProgress,
  escalated,
  resolved;

  /// The API's `status.value`. Only "new" is confirmed so far; the others
  /// are guesses to check with the backend.
  static IssueStatus fromApi(String value) => switch (value) {
    'new' => submitted,
    'in_progress' => inProgress,
    'escalated' => escalated,
    'resolved' || 'closed' => resolved,
    // An unknown status is still an open issue; better than failing the
    // whole list.
    _ => inProgress,
  };
}

/// What an issue is about ("Financial", "Housing"…). Categories are managed
/// on the server, so they're data, not an enum.
class IssueCategory {
  final int id;

  /// Comes from the server in English only, for now.
  final String name;

  const IssueCategory({required this.id, required this.name});

  factory IssueCategory.fromJson(Map<String, dynamic> json) =>
      IssueCategory(id: json['id'] as int, name: json['name'] as String);

  // Two categories are the same if their ids are, even when they're
  // different objects (e.g. fetched twice). The dropdown relies on this to
  // find the selected value among its options.
  @override
  bool operator ==(Object other) => other is IssueCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
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
  final int id;
  final String title;
  final IssueCategory category;
  final IssueStatus status;
  final DateTime createdAt;

  /// Days until the deadline; negative when overdue. Null when there's no
  /// deadline (the API doesn't send one yet).
  final int? dueInDays;

  /// Who is handling the issue, or null if not assigned yet.
  final String? assignedTo;

  /// What the user wrote when reporting; may be empty.
  final String description;

  /// Employer or embassy the issue is about; may be empty.
  final String concerned;

  /// Steps in order: completed ones first, then upcoming ones.
  final List<IssueEvent> timeline;

  const Issue({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdAt,
    this.dueInDays,
    this.assignedTo,
    this.description = '',
    this.concerned = '',
    this.timeline = const [],
  });

  /// Parses one item of `GET /issues` (`data[]`).
  factory Issue.fromJson(Map<String, dynamic> json) {
    final status = IssueStatus.fromApi(
      (json['status'] as Map<String, dynamic>)['value'] as String,
    );
    final createdAt = DateTime.parse(json['created_at'] as String).toLocal();
    return Issue(
      id: json['id'] as int,
      title: json['subject'] as String,
      category: IssueCategory.fromJson(
        json['issue_category'] as Map<String, dynamic>,
      ),
      status: status,
      createdAt: createdAt,
      assignedTo: _assigneeName(json['assigned_to']),
      description: json['description'] as String? ?? '',
      concerned: json['employer'] as String? ?? '',
      // The list only says when it was submitted. The full history comes
      // from `GET /issues/{id}/updates`, to be used by Track issue.
      timeline: [
        IssueEvent(IssueEventType.submitted, createdAt),
        const IssueEvent(IssueEventType.assignedToEmployer),
        const IssueEvent(IssueEventType.resolved),
      ],
    );
  }

  /// `assigned_to` has only been seen as null; accept a name or a
  /// `{name: …}` object until the backend confirms its shape.
  static String? _assigneeName(Object? value) => switch (value) {
    String name => name,
    {'name': String name} => name,
    _ => null,
  };

  /// Shown where the design has a reference number ("GN-2083-004512").
  /// The API only has an id so far.
  String get reference => '#$id';

  bool get isOverdue => dueInDays != null && dueInDays! < 0;
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
