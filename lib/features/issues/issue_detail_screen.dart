import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/back_title_bar.dart';
import '../../widgets/status_pill.dart';
import 'data/issues_provider.dart';
import 'models/issue.dart';
import 'widgets/issue_timeline.dart';

/// "Track issue": one issue's details and progress timeline.
class IssueDetailScreen extends ConsumerWidget {
  final String reference;

  const IssueDetailScreen({super.key, required this.reference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final issue = ref.watch(issueByReferenceProvider(reference));

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              TSizes.pagePadding,
              topPadding,
              TSizes.pagePadding,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BackTitleBar(
                  title: l10n.trackIssueTitle,
                  fallbackLocation: '/issues',
                ),
                const SizedBox(height: TSizes.timelineGap),
                if (issue == null)
                  Text(
                    l10n.issueNotFound,
                    style: TTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  )
                else ...[
                  _IssueSummary(issue: issue),
                  const SizedBox(height: TSizes.timelineGap),
                  IssueTimeline(issue: issue),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IssueSummary extends StatelessWidget {
  final Issue issue;

  const _IssueSummary({required this.issue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          issue.reference,
          style: TTextStyles.label.copyWith(color: colors.primary),
        ),
        const SizedBox(height: TSizes.sm),
        Text(
          issue.title,
          style: TTextStyles.headlineSmall.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: TSizes.sm),
        Row(
          children: [
            StatusPill(status: issue.status),
            const SizedBox(width: TSizes.sm),
            Text(
              issue.isOverdue ? l10n.overdue : l10n.dueInDays(issue.dueInDays),
              style: TTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
