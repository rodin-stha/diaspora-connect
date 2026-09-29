import 'package:flutter/material.dart';

import '../features/issues/models/issue.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

class StatusPill extends StatelessWidget {
  final IssueStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final (label, background, foreground) = switch (status) {
      IssueStatus.inProgress => (
        l10n.statusInProgress,
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      IssueStatus.escalated => (
        l10n.statusEscalated,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TSizes.pillRadius),
      ),
      child: Text(
        label,
        style: TTextStyles.caption.copyWith(color: foreground),
      ),
    );
  }
}
