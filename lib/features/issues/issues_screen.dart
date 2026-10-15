import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/issue_card.dart';
import '../../widgets/load_error.dart';
import '../../widgets/load_more_scroll_view.dart';
import '../../widgets/search_field.dart';
import '../../widgets/selectable_chip.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/soft_bouncing_scroll_physics.dart';
import 'data/issues_provider.dart';
import 'models/issue_filter.dart';

// Placeholder cards while the first page loads.
const _skeletonCount = 3;

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  // Temporary UI state: only this screen cares, so it lives here, not in
  // a provider.
  IssueFilter _filter = IssueFilter.all;

  /// The search text sent to the server. Updated a moment after the user
  /// stops typing, not on every key (see [_onSearchChanged]).
  String _search = '';
  Timer? _searchDebounce;

  @override
  void dispose() {
    // Timers keep running after the screen closes unless cancelled.
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// Waits until the user pauses before searching, so typing "salary"
  /// sends one request instead of six.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final search = value.trim();
      if (search != _search) setState(() => _search = search);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final IssueQuery query = (search: _search, filter: _filter);

    // All issues: for the "All (n)" count, and to tell "no issues yet"
    // apart from "nothing matches".
    final allIssuesAsync = ref.watch(issuesProvider);
    final allIssues = allIssuesAsync.value;
    // What the list shows. With no search or filter that's the same list,
    // so reuse it instead of fetching it twice.
    final issuesAsync = query.isEmpty
        ? allIssuesAsync
        : ref.watch(issueSearchProvider(query));
    final shown = issuesAsync.value;
    void loadMore() => query.isEmpty
        ? ref.read(issuesProvider.notifier).loadMore()
        : ref.read(issueSearchProvider(query).notifier).loadMore();

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status bar icons on the light background
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          // Pull down to fetch the latest, e.g. after a case worker updates
          // an issue.
          body: RefreshIndicator(
            // Both lists: the count comes from all issues. Future.wait keeps
            // the spinner until both have arrived.
            onRefresh: () => Future.wait([
              ref.refresh(issuesProvider.future),
              if (!query.isEmpty)
                ref.refresh(issueSearchProvider(query).future),
            ]),
            // A SingleChildScrollView is only as tall as its content, so on a
            // short list the empty space below wouldn't react to the pull.
            // Filling the screen makes the whole page draggable.
            child: SizedBox.expand(
              child: LoadMoreScrollView(
                canLoadMore:
                    shown != null && shown.hasMore && !shown.loadMoreFailed,
                onLoadMore: loadMore,
                // Bouncing: the page follows the finger on a pull and glides
                // back on release (Android would otherwise stay put).
                // AlwaysScrollable as parent keeps that working on a short list.
                physics: const SoftBouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  TSizes.pagePadding,
                  topPadding,
                  TSizes.pagePadding,
                  TSizes.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.issuesTitle,
                      style: TTextStyles.titleLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: TSizes.listGap),
                    SearchField(
                      hintText: l10n.searchIssuesHint,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: TSizes.listGap),
                    Wrap(
                      spacing: 3,
                      runSpacing: TSizes.sm,
                      children: [
                        for (final filter in IssueFilter.values)
                          SelectableChip(
                            label: _filterLabel(
                              l10n,
                              filter,
                              // All of them, not just the pages loaded so far.
                              allIssues?.total ?? allIssues?.items.length ?? 0,
                            ),
                            isSelected: filter == _filter,
                            onTap: () => setState(() => _filter = filter),
                          ),
                      ],
                    ),
                    const SizedBox(height: TSizes.listGap),
                    issuesAsync.when(
                      data: (issues) {
                        if (allIssues != null && allIssues.items.isEmpty) {
                          return EmptyState(
                            iconAsset: 'assets/icons/inbox.svg',
                            message: l10n.noIssuesYet,
                            actionLabel: l10n.reportNewIssue,
                            onAction: () => context.push('/report-issue'),
                          );
                        }
                        // The issues exist, a search or filter hides them all:
                        // no icon or "report" link, just say so.
                        if (issues.items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              l10n.noIssuesFound,
                              textAlign: TextAlign.center,
                              style: TTextStyles.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: TSizes.listGap,
                          children: [
                            for (final issue in issues.items)
                              IssueCard(
                                issue: issue,
                                showCategory: true,
                                onTap: () =>
                                    context.push('/issues/${issue.reference}'),
                              ),
                            if (issues.isLoadingMore || issues.loadMoreFailed)
                              LoadMoreFooter(
                                isLoading: issues.isLoadingMore,
                                failed: issues.loadMoreFailed,
                                errorMessage: l10n.errorLoadIssues,
                                onRetry: loadMore,
                                skeleton: const IssueCardSkeleton(),
                              ),
                          ],
                        );
                      },
                      // Placeholder cards in the shape of the real ones, so
                      // nothing jumps when the issues arrive.
                      loading: () => Skeleton(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: TSizes.listGap,
                          children: [
                            for (var i = 0; i < _skeletonCount; i++)
                              const IssueCardSkeleton(),
                          ],
                        ),
                      ),
                      error: (error, _) => LoadError(
                        message: l10n.errorLoadIssues,
                        onRetry: () => query.isEmpty
                            ? ref.invalidate(issuesProvider)
                            : ref.invalidate(issueSearchProvider(query)),
                      ),
                      // Retry after an error shows the spinner; a pull-to-refresh
                      // keeps the list (the pull has its own spinner).
                      skipLoadingOnRefresh: !issuesAsync.hasError,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _filterLabel(
    AppLocalizations l10n,
    IssueFilter filter,
    int totalCount,
  ) => switch (filter) {
    IssueFilter.all => l10n.filterAll(totalCount),
    IssueFilter.inProgress => l10n.filterInProgress,
    IssueFilter.assigned => l10n.filterAssigned,
    IssueFilter.resolved => l10n.filterResolved,
  };
}
