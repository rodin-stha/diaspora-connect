import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import '../features/issues/models/issue.dart';
import 'status_pill.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;

  const IssueCard({super.key, required this.issue, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(TSizes.cardRadius);
    final dueLabel = issue.isOverdue
        ? l10n.overdue
        : l10n.dueInDays(issue.dueInDays);

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
                      '${issue.reference} · $dueLabel',
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
