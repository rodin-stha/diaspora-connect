import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// One issue by its reference number, or null if there's none. Loading and
/// errors come from [issuesProvider].
final issueByReferenceProvider = Provider.family<AsyncValue<Issue?>, String>(
  (ref, reference) => ref
      .watch(issuesProvider)
      .whenData(
        (issues) =>
            issues.where((issue) => issue.reference == reference).firstOrNull,
      ),
);
