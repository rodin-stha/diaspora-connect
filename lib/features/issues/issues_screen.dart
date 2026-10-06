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
import '../../widgets/search_field.dart';
import '../../widgets/selectable_chip.dart';
import 'data/issues_provider.dart';
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
    final totalCount = issuesAsync.value?.length ?? 0;

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
            onRefresh: () => ref.refresh(issuesProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: TSizes.listGap),
                  Wrap(
                    spacing: 3,
                    runSpacing: TSizes.sm,
                    children: [
                      for (final filter in IssueFilter.values)
                        SelectableChip(
                          label: _filterLabel(l10n, filter, totalCount),
                          isSelected: filter == _filter,
                          onTap: () => setState(() => _filter = filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: TSizes.listGap),
                  issuesAsync.when(
                    data: (issues) {
                      final visibleIssues = issues
                          .where(
                            (issue) =>
                                _filter.matches(issue) &&
                                issue.matchesSearch(_query),
                          )
                          .toList();
                      if (issues.isEmpty) {
                        return EmptyState(
                          iconAsset: 'assets/icons/inbox.svg',
                          message: l10n.noIssuesYet,
                          actionLabel: l10n.reportNewIssue,
                          onAction: () => context.push('/report-issue'),
                        );
                      }
                      // The issues exist, a search or filter hides them all:
                      // no icon or "report" link, just say so.
                      if (visibleIssues.isEmpty) {
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
                          for (final issue in visibleIssues)
                            IssueCard(
                              issue: issue,
                              showCategory: true,
                              onTap: () =>
                                  context.push('/issues/${issue.reference}'),
                            ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => LoadError(
                      message: l10n.errorLoadIssues,
                      onRetry: () => ref.invalidate(issuesProvider),
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
