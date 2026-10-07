import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_exception.dart';
import '../models/issue.dart';
import '../models/issue_filter.dart';
import '../models/new_issue.dart';
import 'issues_repository.dart';

/// All of the current user's issues, newest first. The single source of
/// truth for Home, the Issues screen and Track issue.
final issuesProvider = AsyncNotifierProvider<IssuesNotifier, List<Issue>>(
  IssuesNotifier.new,
);

/// The categories to choose from when reporting an issue. Fetched once and
/// cached for the session.
final issueCategoriesProvider = FutureProvider<List<IssueCategory>>(
  (ref) => ref.read(issuesRepositoryProvider).fetchCategories(),
);

class IssuesNotifier extends AsyncNotifier<List<Issue>> {
  @override
  Future<List<Issue>> build() =>
      ref.read(issuesRepositoryProvider).fetchIssues();

  /// Fetches the list again in the background, e.g. to check for changes.
  /// No loading state, and a failure (offline…) keeps the current list:
  /// the user didn't ask for this, so it shouldn't replace the list with
  /// a spinner or an error.
  Future<void> refreshQuietly() async {
    try {
      final issues = await ref.read(issuesRepositoryProvider).fetchIssues();
      state = AsyncData(issues);
    } on ApiException {
      // Try again on the next check.
    }
  }

  /// Sends a new issue to the API, then fetches the list again so it
  /// includes the issue as the server saved it. Throws [ApiException] if
  /// sending fails.
  Future<void> submit(NewIssue issue) async {
    await ref.read(issuesRepositoryProvider).createIssue(issue);
    ref.invalidateSelf();
    // Any open search may now match the new issue too.
    ref.invalidate(issueSearchProvider);
  }
}

/// Issues matching a search and/or filter chip, as the server finds them.
///
/// A family: one cached result per [IssueQuery] (like a React Query key).
/// autoDispose: results for queries no longer on screen are dropped.
final issueSearchProvider = FutureProvider.autoDispose
    .family<List<Issue>, IssueQuery>(
      (ref, query) => ref
          .read(issuesRepositoryProvider)
          .fetchIssues(
            search: query.search.isEmpty ? null : query.search,
            type: query.filter.apiValue,
          ),
    );

/// One issue with its status history, for Track issue. Fetched on its own
/// because the list doesn't include the history, and so it works for any
/// issue (e.g. opened from an alert), not just the first page.
///
/// autoDispose: fetched fresh each time the screen opens.
final issueDetailProvider = FutureProvider.autoDispose.family<Issue, String>(
  (ref, reference) => ref.read(issuesRepositoryProvider).fetchIssue(reference),
);
