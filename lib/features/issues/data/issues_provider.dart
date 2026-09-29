import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';

/// All of the current user's issues. The single source of truth for both
/// Home and the Issues screen.
///
/// Returns sample data until the backend API exists; only this provider will
/// need to change then.
final issuesProvider = Provider<List<Issue>>((ref) => _sampleIssues);

const _sampleIssues = [
  Issue(
    title: 'Wage shortfall, October pay',
    reference: 'GN-2083-004512',
    category: IssueCategory.wages,
    dueInDays: 4,
    status: IssueStatus.inProgress,
    assignedTo: 'Case worker',
  ),
  Issue(
    title: 'Permit renewal delayed',
    reference: 'GN-2083-004498',
    category: IssueCategory.permit,
    dueInDays: -1,
    status: IssueStatus.escalated,
    assignedTo: 'Case worker',
  ),
  Issue(
    title: 'Housing dispute, live-in contract',
    reference: 'GN-2083-004530',
    category: IssueCategory.housing,
    dueInDays: 6,
    status: IssueStatus.submitted,
  ),
  Issue(
    title: 'Passport held by employer',
    reference: 'GN-2083-004533',
    category: IssueCategory.documents,
    dueInDays: 2,
    status: IssueStatus.escalated,
    assignedTo: 'Case worker',
  ),
];
