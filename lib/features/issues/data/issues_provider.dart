import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue.dart';
import 'issues_api.dart';

/// All of the current user's issues, newest first. The single source of
/// truth for Home, the Issues screen and Track issue.
///
/// Async: screens get an `AsyncValue` (loading / error / data) and must
/// handle all three. Only the first page for now.
final issuesProvider = AsyncNotifierProvider<IssuesNotifier, List<Issue>>(
  IssuesNotifier.new,
);

class IssuesNotifier extends AsyncNotifier<List<Issue>> {
  @override
  Future<List<Issue>> build() => ref.watch(issuesApiProvider).fetchIssues();

  /// Fetches again (pull to refresh, Try again). Completes when done, so a
  /// `RefreshIndicator` knows when to stop spinning.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// TEMPORARY, until the form uses `POST /issues`: adds a newly reported
  /// issue at the top on this device only, and returns it.
  Issue report({
    required IssueCategory category,
    required String subject,
    String description = '',
    String concerned = '',
  }) {
    final current = state.value ?? const [];
    final now = DateTime.now();
    final issue = Issue(
      // The server will assign real ids.
      id: current.fold(0, (highest, i) => i.id > highest ? i.id : highest) + 1,
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
    state = AsyncData([issue, ...current]);
    return issue;
  }
}

/// One issue by its id, or null if it's not (or not yet) loaded.
final issueByIdProvider = Provider.family<Issue?, int>(
  (ref, id) =>
      ref.watch(issuesProvider).value?.where((i) => i.id == id).firstOrNull,
);

/// Categories for the Report an issue form. Fetched once and cached while
/// the app runs.
final issueCategoriesProvider = FutureProvider<List<IssueCategory>>(
  (ref) => ref.watch(issuesApiProvider).fetchCategories(),
);
