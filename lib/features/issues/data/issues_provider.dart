import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_exception.dart';
import '../../../app/api/paged.dart';
import '../../../app/api/paged_notifier.dart';
import '../models/issue.dart';
import '../models/issue_filter.dart';
import '../models/new_issue.dart';
import 'issues_repository.dart';

/// How many issues to fetch at a time.
const _issuesPerPage = 20;

/// The current user's issues, newest first, loaded a page at a time as the
/// Issues screen scrolls. Also what in-app alerts watch for changes.
final issuesProvider = AsyncNotifierProvider<IssuesNotifier, PagedList<Issue>>(
  IssuesNotifier.new,
);

/// The categories to choose from when reporting an issue. Fetched once and
/// cached for the session.
final issueCategoriesProvider = FutureProvider<List<IssueCategory>>(
  (ref) => ref.read(issuesRepositoryProvider).fetchCategories(),
);

class IssuesNotifier extends PagedNotifier<Issue> {
  @override
  int get perPage => _issuesPerPage;

  @override
  Future<Paged<Issue>> fetchPage({required int page, required int perPage}) =>
      ref
          .read(issuesRepositoryProvider)
          .fetchIssues(page: page, perPage: perPage);

  @override
  Object idOf(Issue item) => item.reference;

  /// Fetches the loaded issues again in the background, e.g. to check for
  /// changes. No loading state, and a failure (offline…) keeps the current
  /// list: the user didn't ask for this, so it shouldn't replace the list
  /// with a spinner or an error.
  Future<void> refreshQuietly() async {
    try {
      await reloadLoaded();
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

  /// Sends the user's answer on an issue that needs info, then fetches the
  /// issue and the lists again: the reply may have changed its status.
  /// Throws [ApiException] if sending fails.
  Future<void> reply(
    String reference, {
    required String message,
    String? photoPath,
  }) async {
    await ref
        .read(issuesRepositoryProvider)
        .replyToIssue(reference, message: message, photoPath: photoPath);
    ref.invalidate(issueDetailProvider(reference));
    ref.invalidateSelf();
    ref.invalidate(issueSearchProvider);
  }
}

/// Issues matching a search and/or filter chip, as the server finds them,
/// a page at a time.
///
/// A family: one cached result per [IssueQuery] (like a React Query key).
/// autoDispose: results for queries no longer on screen are dropped.
final issueSearchProvider = AsyncNotifierProvider.autoDispose
    .family<IssueSearchNotifier, PagedList<Issue>, IssueQuery>(
      IssueSearchNotifier.new,
    );

class IssueSearchNotifier extends PagedNotifier<Issue> {
  /// Riverpod passes each family member its query through the constructor.
  final IssueQuery query;

  IssueSearchNotifier(this.query);

  @override
  int get perPage => _issuesPerPage;

  @override
  Future<Paged<Issue>> fetchPage({required int page, required int perPage}) =>
      ref
          .read(issuesRepositoryProvider)
          .fetchIssues(
            page: page,
            perPage: perPage,
            search: query.search.isEmpty ? null : query.search,
            type: query.filter.apiValue,
          );

  @override
  Object idOf(Issue item) => item.reference;
}

/// One issue with its status history, for Track issue. Fetched on its own
/// because the list doesn't include the history, and so it works for any
/// issue (e.g. opened from an alert), not just the first page.
///
/// autoDispose: fetched fresh each time the screen opens.
final issueDetailProvider = FutureProvider.autoDispose.family<Issue, String>(
  (ref, reference) => ref.read(issuesRepositoryProvider).fetchIssue(reference),
);
