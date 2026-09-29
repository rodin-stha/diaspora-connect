import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/issue_card.dart';
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
    final allIssues = ref.watch(issuesProvider);
    final visibleIssues = allIssues
        .where((issue) => _filter.matches(issue) && issue.matchesSearch(_query))
        .toList();

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Dark status bar icons on the light background
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SingleChildScrollView(
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
              if (visibleIssues.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    l10n.noIssuesFound,
                    textAlign: TextAlign.center,
                    style: TTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                for (final (index, issue) in visibleIssues.indexed) ...[
                  if (index > 0) const SizedBox(height: TSizes.listGap),
                  IssueCard(issue: issue, showCategory: true),
                ],
            ],
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
