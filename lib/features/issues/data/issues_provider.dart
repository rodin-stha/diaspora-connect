import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';

/// All of the current user's issues, newest first. The single source of
/// truth for Home, the Issues screen and Track issue.
///
/// Returns sample data until the backend API exists; only this provider will
/// need to change then.
final issuesProvider = NotifierProvider<IssuesNotifier, List<Issue>>(
  IssuesNotifier.new,
);

class IssuesNotifier extends Notifier<List<Issue>> {
  /// Days a new issue has before its first deadline.
  static const _defaultDueInDays = 7;

  @override
  List<Issue> build() => _sampleIssues;

  /// Adds a newly reported issue at the top and returns it (with its new
  /// reference number).
  Issue report({
    required IssueCategory category,
    required String subject,
    String description = '',
    String concerned = '',
  }) {
    final issue = Issue(
      title: subject,
      reference: _nextReference(),
      category: category,
      dueInDays: _defaultDueInDays,
      status: IssueStatus.submitted,
      description: description,
      concerned: concerned,
      timeline: [
        IssueEvent(IssueEventType.submitted, DateTime.now()),
        const IssueEvent(IssueEventType.assignedToEmployer),
        const IssueEvent(IssueEventType.resolved),
      ],
    );
    state = [issue, ...state];
    return issue;
  }

  /// "GN-2083-004534": one more than the highest number so far. The backend
  /// will assign real reference numbers.
  String _nextReference() {
    final highest = state
        .map((issue) => int.parse(issue.reference.split('-').last))
        .fold(0, (a, b) => a > b ? a : b);
    return 'GN-2083-${(highest + 1).toString().padLeft(6, '0')}';
  }
}

/// One issue by its reference number, or null if there's none.
final issueByReferenceProvider = Provider.family<Issue?, String>(
  (ref, reference) => ref
      .watch(issuesProvider)
      .where((issue) => issue.reference == reference)
      .firstOrNull,
);

// `final`, not `const`: DateTime has no const constructor.
final _sampleIssues = [
  Issue(
    title: 'Wage shortfall, October pay',
    reference: 'DC-2083-004512',
    category: IssueCategory.wages,
    dueInDays: 4,
    status: IssueStatus.inProgress,
    assignedTo: 'Case worker',
    timeline: [
      IssueEvent(IssueEventType.submitted, DateTime(2026, 9, 3, 10, 42)),
      IssueEvent(
        IssueEventType.assignedToEmployer,
        DateTime(2026, 9, 3, 14, 5),
      ),
      IssueEvent(
        IssueEventType.escalatedToEmbassy,
        DateTime(2026, 9, 5, 11, 20),
      ),
      IssueEvent(IssueEventType.resolved),
    ],
  ),
  Issue(
    title: 'Permit renewal delayed',
    reference: 'DC-2083-004498',
    category: IssueCategory.permit,
    dueInDays: -1,
    status: IssueStatus.escalated,
    assignedTo: 'Case worker',
    timeline: [
      IssueEvent(IssueEventType.submitted, DateTime(2026, 8, 28, 9, 10)),
      IssueEvent(
        IssueEventType.assignedToEmployer,
        DateTime(2026, 8, 29, 11, 30),
      ),
      IssueEvent(
        IssueEventType.escalatedToEmbassy,
        DateTime(2026, 9, 2, 16, 45),
      ),
      IssueEvent(IssueEventType.resolved),
    ],
  ),
  Issue(
    title: 'Housing dispute, live-in contract',
    reference: 'DC-2083-004530',
    category: IssueCategory.housing,
    dueInDays: 6,
    status: IssueStatus.submitted,
    timeline: [
      IssueEvent(IssueEventType.submitted, DateTime(2026, 9, 6, 8, 20)),
      IssueEvent(IssueEventType.assignedToEmployer),
      IssueEvent(IssueEventType.resolved),
    ],
  ),
  Issue(
    title: 'Passport held by employer',
    reference: 'DC-2083-004533',
    category: IssueCategory.documents,
    dueInDays: 2,
    status: IssueStatus.escalated,
    assignedTo: 'Case worker',
    timeline: [
      IssueEvent(IssueEventType.submitted, DateTime(2026, 9, 4, 19, 5)),
      IssueEvent(
        IssueEventType.assignedToEmployer,
        DateTime(2026, 9, 5, 9, 30),
      ),
      IssueEvent(
        IssueEventType.escalatedToEmbassy,
        DateTime(2026, 9, 5, 15, 10),
      ),
      IssueEvent(IssueEventType.resolved),
    ],
  ),
];
