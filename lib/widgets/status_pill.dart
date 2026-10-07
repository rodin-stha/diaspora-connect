import 'package:flutter/material.dart';

import '../features/issues/models/issue.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// An issue status as the user sees it ("In progress").
String issueStatusLabel(AppLocalizations l10n, IssueStatus status) =>
    switch (status) {
      IssueStatus.submitted => l10n.statusNew,
      IssueStatus.assigned => l10n.statusAssigned,
      IssueStatus.inProgress => l10n.statusInProgress,
      IssueStatus.escalated => l10n.statusEscalated,
      IssueStatus.resolved => l10n.statusResolved,
      IssueStatus.rejected => l10n.statusRejected,
    };

class StatusPill extends StatelessWidget {
  final IssueStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = issueStatusLabel(AppLocalizations.of(context), status);
    final (background, foreground) = switch (status) {
      IssueStatus.submitted => (
        colors.infoContainer,
        colors.onInfoContainer,
      ),
      // Same colours as New: still waiting for work to start.
      IssueStatus.assigned => (
        colors.infoContainer,
        colors.onInfoContainer,
      ),
      IssueStatus.inProgress => (
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      IssueStatus.escalated => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      IssueStatus.rejected => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      IssueStatus.resolved => (
        colors.successContainer,
        colors.onSuccessContainer,
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
