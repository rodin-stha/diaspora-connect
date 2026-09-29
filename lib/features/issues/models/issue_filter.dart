import 'issue.dart';

/// The filter chips on the Issues screen.
enum IssueFilter {
  all,

  /// Active issues, including escalated ones (still open, just more urgent).
  inProgress,

  /// A case worker is handling it, whatever its status.
  assigned,
  resolved;

  bool matches(Issue issue) => switch (this) {
    IssueFilter.all => true,
    IssueFilter.inProgress =>
      issue.status == IssueStatus.inProgress ||
          issue.status == IssueStatus.escalated,
    IssueFilter.assigned => issue.isAssigned,
    IssueFilter.resolved => issue.status == IssueStatus.resolved,
  };
}
