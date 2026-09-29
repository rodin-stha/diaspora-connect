import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';

/// All of the current user's issues. The single source of truth for both
/// Home and the Issues screen.
///
/// Returns sample data until the backend API exists; only this provider will
/// need to change then.
final issuesProvider = Provider<List<Issue>>((ref) => _sampleIssues);

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
    reference: 'GN-2083-004512',
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
    reference: 'GN-2083-004498',
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
    reference: 'GN-2083-004530',
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
    reference: 'GN-2083-004533',
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
