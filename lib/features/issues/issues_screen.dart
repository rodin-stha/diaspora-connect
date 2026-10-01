import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
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
    // Empty while loading or failed, so the chips still show ("All · 0").
    final allIssues = issuesAsync.value ?? const <Issue>[];

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status bar icons on the light background
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        // Pull down to fetch again. Needs a scroll view that can always be
        // pulled, even when the list is too short to scroll.
        body: RefreshIndicator(
          onRefresh: () => ref.read(issuesProvider.notifier).refresh(),
          edgeOffset: topPadding,
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
                  spacing: TSizes.sm,
                  runSpacing: TSizes.sm,
                  children: [
                    for (final filter in IssueFilter.values)
                      SelectableChip(
                        label: _filterLabel(l10n, filter, allIssues.length),
                        isSelected: filter == _filter,
                        onTap: () => setState(() => _filter = filter),
                      ),
                  ],
                ),
                const SizedBox(height: TSizes.listGap),
                // `when` makes us handle every state, like a React Query
                // `isLoading` / `isError` / `data` check.
                issuesAsync.when(
                  // On refresh, keep showing the old list (the spinner at
                  // the top says something's happening).
                  skipLoadingOnRefresh: true,
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => _LoadError(
                    onRetry: () => ref.read(issuesProvider.notifier).refresh(),
                  ),
                  data: (issues) => issues.isEmpty
                      ? _Message(text: l10n.noIssuesYet)
                      : _IssueList(
                          issues: issues
                              .where(
                                (issue) =>
                                    _filter.matches(issue) &&
                                    issue.matchesSearch(_query),
                              )
                              .toList(),
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

class _IssueList extends StatelessWidget {
  final List<Issue> issues;

  const _IssueList({required this.issues});

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return _Message(text: AppLocalizations.of(context).noIssuesFound);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: TSizes.listGap,
      children: [
        for (final issue in issues)
          IssueCard(
            issue: issue,
            showCategory: true,
            onTap: () => context.push('/issues/${issue.id}'),
          ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _Message(text: l10n.issuesLoadError),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
      ],
    );
  }
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
