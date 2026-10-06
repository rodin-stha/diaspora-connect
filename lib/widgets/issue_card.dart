import 'package:flutter/material.dart';

import '../features/issues/models/issue.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'skeleton.dart';
import 'status_pill.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;

  /// Adds the category ("Wages", "Permit"…) to the subtitle. Shown on the
  /// Issues list, hidden on Home.
  final bool showCategory;

  const IssueCard({
    super.key,
    required this.issue,
    this.onTap,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(TSizes.cardRadius);
    final subtitle = [
      issue.reference,
      if (showCategory) issue.category.name,
      issue.isOverdue ? l10n.overdue : l10n.dueInDays(issue.dueInDays),
    ].join(' · ');

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: TTextStyles.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: TSizes.xs),
                    Text(
                      subtitle,
                      style: TTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TSizes.md),
              StatusPill(status: issue.status),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stands in for an [IssueCard] while issues load: same size and shape,
/// with grey bars where the title, subtitle and status go. Wrap a group of
/// them in one [Skeleton] so they pulse together.
class IssueCardSkeleton extends StatelessWidget {
  const IssueCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(TSizes.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fractions of the width, so it looks right on any phone.
                const FractionallySizedBox(
                  widthFactor: 0.7,
                  child: SkeletonBox(height: 14),
                ),
                const SizedBox(height: TSizes.sm),
                const FractionallySizedBox(
                  widthFactor: 0.45,
                  child: SkeletonBox(height: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: TSizes.md),
          const SkeletonBox(width: 64, height: 24, radius: TSizes.pillRadius),
        ],
      ),
    );
  }
}
