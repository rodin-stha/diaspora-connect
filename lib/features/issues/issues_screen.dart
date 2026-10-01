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
import '../../widgets/issue_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/selectable_chip.dart';
import 'data/issues_provider.dart';
import 'models/issue.dart';
import 'models/issue_filter.dart';

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  // Temporary UI state: only this screen cares, so it lives here, not in
  // a provider.
  IssueFilter _filter = IssueFilter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final issuesAsync = ref.watch(issuesProvider);
    final notifier = ref.read(issuesProvider.notifier);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status bar icons on the light background
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          // Pull down to fetch again. Needs a scroll view that can always be
          // pulled, even when the list is too short to scroll.
          body: RefreshIndicator(
            onRefresh: notifier.refresh,
            edgeOffset: topPadding,
            // Slivers build lazily: only the cards near the screen exist, so
            // the "load more" footer is only built when the user nears the
            // end. (A Column would build everything at once.)
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    TSizes.pagePadding,
                    topPadding,
                    TSizes.pagePadding,
                    TSizes.xl,
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
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
                              onChanged: (value) =>
                                  setState(() => _query = value),
                            ),
                            const SizedBox(height: TSizes.listGap),
                            Wrap(
                              spacing: 3,
                              runSpacing: TSizes.sm,
                              children: [
                                for (final filter in IssueFilter.values)
                                  SelectableChip(
                                    // All issues on the server, not just the
                                    // pages loaded so far.
                                    label: _filterLabel(
                                      l10n,
                                      filter,
                                      issuesAsync.value?.total ?? 0,
                                    ),
                                    isSelected: filter == _filter,
                                    onTap: () =>
                                        setState(() => _filter = filter),
                                  ),
                              ],
                            ),
                            const SizedBox(height: TSizes.listGap),
                          ],
                        ),
                      ),
                      // `when` makes us handle every state, like a React
                      // Query `isLoading` / `isError` / `data` check. It's
                      // about the first page; later pages show in the footer.
                      issuesAsync.when(
                        // On refresh, keep showing the old list (the spinner
                        // at the top says something's happening).
                        skipLoadingOnRefresh: true,
                        loading: () => const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (error, _) => SliverToBoxAdapter(
                          child: _LoadError(
                            message: l10n.issuesLoadError,
                            onRetry: notifier.refresh,
                          ),
                        ),
                        data: (state) => state.issues.isEmpty
                            ? SliverToBoxAdapter(
                                child: _Message(text: l10n.noIssuesYet),
                              )
                            : _IssueList(
                                state: state,
                                // Only filters the pages loaded so far; the
                                // API has no search or filter parameters yet.
                                visibleIssues: state.issues
                                    .where(
                                      (issue) =>
                                          _filter.matches(issue) &&
                                          issue.matchesSearch(_query),
                                    )
                                    .toList(),
                                onLoadMore: notifier.loadMore,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
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

/// The issue cards, then a footer that loads the next page.
class _IssueList extends StatelessWidget {
  final IssuesState state;
  final List<Issue> visibleIssues;
  final VoidCallback onLoadMore;

  const _IssueList({
    required this.state,
    required this.visibleIssues,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverList.separated(
      // +1 for the footer
      itemCount: visibleIssues.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: TSizes.listGap),
      itemBuilder: (context, index) {
        if (index < visibleIssues.length) {
          final issue = visibleIssues[index];
          return IssueCard(
            issue: issue,
            showCategory: true,
            onTap: () => context.push('/issues/${issue.id}'),
          );
        }
        if (state.loadMoreError != null) {
          return _LoadError(message: l10n.loadMoreError, onRetry: onLoadMore);
        }
        if (state.hasMore) {
          // A new key per page, so it fires again for the next page even if
          // it ends up in the same place (e.g. a filter hid the new cards).
          return _LoadMoreTrigger(
            key: ValueKey(state.page),
            onVisible: onLoadMore,
          );
        }
        // Everything is loaded; say so if the filter matched nothing.
        return visibleIssues.isEmpty
            ? _Message(text: l10n.noIssuesFound)
            : const SizedBox.shrink();
      },
    );
  }
}

/// A spinner that asks for the next page as soon as it's built, i.e. when
/// the user scrolls near the end of the list (or the list is too short to
/// scroll at all).
class _LoadMoreTrigger extends StatefulWidget {
  final VoidCallback onVisible;

  const _LoadMoreTrigger({super.key, required this.onVisible});

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    // Not during build: changing provider state while widgets are building
    // is an error, so wait until this frame is done.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: TSizes.md),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Message(text: message),
      OutlinedButton(
        onPressed: onRetry,
        child: Text(AppLocalizations.of(context).tryAgain),
      ),
    ],
  );
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TTextStyles.body.copyWith(color: context.colors.textSecondary),
    ),
  );
}
