/// The filter chips on the Issues screen.
enum IssueFilter {
  all,
  inProgress,

  /// A case worker is handling it, whatever its status.
  assigned,
  resolved;

  /// The `type` query parameter for GET /issues; null for [all], which
  /// sends none.
  String? get apiValue => switch (this) {
    IssueFilter.all => null,
    IssueFilter.inProgress => 'in_progress',
    IssueFilter.assigned => 'assigned',
    IssueFilter.resolved => 'resolved',
  };
}

/// What the Issues screen asks the server for: a search text and a chip.
///
/// A record, so two queries with the same values are equal. That's what
/// lets [issueSearchProvider] reuse a result instead of fetching again.
typedef IssueQuery = ({String search, IssueFilter filter});

extension IssueQueryX on IssueQuery {
  /// No search and "All": the plain list, already in [issuesProvider].
  bool get isEmpty => search.isEmpty && filter == IssueFilter.all;
}
