import 'package:flutter/material.dart';

import '../features/issues/models/issue.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
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
      if (showCategory) _categoryLabel(l10n, issue.category),
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

  static String _categoryLabel(AppLocalizations l10n, IssueCategory category) =>
      switch (category) {
        IssueCategory.wages => l10n.categoryWages,
        IssueCategory.permit => l10n.categoryPermit,
        IssueCategory.housing => l10n.categoryHousing,
        IssueCategory.documents => l10n.categoryDocuments,
      };
}
