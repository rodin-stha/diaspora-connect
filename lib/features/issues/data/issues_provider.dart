import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';
import 'issues_api.dart';

/// The issues loaded so far, and how to get the rest.
class IssuesState {
  /// Newest first; grows a page at a time.
  final List<Issue> issues;

  /// The last page loaded, and how many there are.
  final int page;
  final int lastPage;

  /// Issues across all pages, loaded or not.
  final int total;

  final bool isLoadingMore;

  /// Why the last [IssuesNotifier.loadMore] failed, or null.
  final Object? loadMoreError;

  const IssuesState({
    required this.issues,
    required this.page,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  bool get hasMore => page < lastPage;

  // Not a regular copyWith: `loadMoreError` is cleared unless given, since
  // every change after a failure is either a retry or a success.
  IssuesState copyWith({
    List<Issue>? issues,
    int? page,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) => IssuesState(
    issues: issues ?? this.issues,
    page: page ?? this.page,
    lastPage: lastPage ?? this.lastPage,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: loadMoreError,
  );
}

/// All of the current user's issues, newest first. The single source of
/// truth for Home, the Issues screen and Track issue.
///
/// Starts with the first page; the Issues screen calls [loadMore] as the
/// user scrolls. The `AsyncValue` around it is for the first page only;
/// later pages report through [IssuesState.isLoadingMore] and
/// [IssuesState.loadMoreError], so a failed page 3 doesn't hide pages 1–2.
final issuesProvider = AsyncNotifierProvider<IssuesNotifier, IssuesState>(
  IssuesNotifier.new,
);

class IssuesNotifier extends AsyncNotifier<IssuesState> {
  @override
  Future<IssuesState> build() async {
    final first = await ref.watch(issuesApiProvider).fetchIssues();
    return IssuesState(
      issues: first.issues,
      page: first.page,
      lastPage: first.lastPage,
      total: first.total,
    );
  }

  /// Back to just the first page, fetched again (pull to refresh, Try
  /// again). Completes when done, so a `RefreshIndicator` knows when to stop
  /// spinning.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Appends the next page. Safe to call often: does nothing while a page is
  /// loading or when there are no more.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(issuesApiProvider)
          .fetchIssues(page: current.page + 1);
      // A refresh while this was loading started over; drop this page.
      if (!ref.mounted) return;

      // Issues reported since page 1 loaded push older ones down a page, so
      // the same issue can come back twice.
      final loadedIds = {for (final issue in current.issues) issue.id};
      state = AsyncData(
        current.copyWith(
          issues: [
            ...current.issues,
            ...next.issues.where((issue) => !loadedIds.contains(issue.id)),
          ],
          page: next.page,
          lastPage: next.lastPage,
          total: next.total,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: error),
      );
    }
  }

  /// TEMPORARY, until the form uses `POST /issues`: adds a newly reported
  /// issue at the top on this device only, and returns it.
  Issue report({
    required IssueCategory category,
    required String subject,
    String description = '',
    String concerned = '',
  }) {
    final current = state.value;
    final issues = current?.issues ?? const <Issue>[];
    final now = DateTime.now();
    final issue = Issue(
      // The server will assign real ids.
      id: issues.fold(0, (highest, i) => i.id > highest ? i.id : highest) + 1,
      title: subject,
      category: category,
      status: IssueStatus.submitted,
      createdAt: now,
      description: description,
      concerned: concerned,
      timeline: [
        IssueEvent(IssueEventType.submitted, now),
        const IssueEvent(IssueEventType.assignedToEmployer),
        const IssueEvent(IssueEventType.resolved),
      ],
    );
    state = AsyncData(
      current == null
          ? IssuesState(issues: [issue], page: 1, lastPage: 1, total: 1)
          : current.copyWith(
              issues: [issue, ...issues],
              total: current.total + 1,
            ),
    );
    return issue;
  }
}

/// One issue by its id, or null if it's not (or not yet) loaded.
final issueByIdProvider = Provider.family<Issue?, int>(
  (ref, id) => ref
      .watch(issuesProvider)
      .value
      ?.issues
      .where((i) => i.id == id)
      .firstOrNull,
);

/// Categories for the Report an issue form. Fetched once and cached while
/// the app runs.
final issueCategoriesProvider = FutureProvider<List<IssueCategory>>(
  (ref) => ref.watch(issuesApiProvider).fetchCategories(),
);
