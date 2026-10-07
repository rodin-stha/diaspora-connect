import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/dot_list_item.dart';
import '../../../widgets/status_pill.dart';
import '../models/issue.dart';

/// An issue's status history, oldest first. Every dot is grey, except the
/// latest change once the issue has ended: green if resolved, red if
/// rejected.
class IssueTimeline extends StatelessWidget {
  final Issue issue;

  const IssueTimeline({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final history = issue.history;

    final outcomeColor = switch (issue.status) {
      IssueStatus.resolved => colors.onSuccessContainer,
      IssueStatus.rejected => colors.onErrorContainer,
      _ => colors.iconInactive, // Still open: no outcome yet.
    };
    bool isLast(int index) => index == history.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, change) in history.indexed)
          DotListItem(
            // The first entry is the report itself: "Submitted" reads
            // better there than the status name "New".
            title: index == 0
                ? l10n.timelineSubmitted
                : issueStatusLabel(l10n, change.status),
            details: [TFormatters.dateTime(context, change.date)],
            // Same grey as read items on Activity.
            dotColor: isLast(index) ? outcomeColor : colors.iconInactive,
            // The last entry has no line below it.
            connectorColor: isLast(index) ? null : colors.connector,
            showConnectorArrow: true,
            bottomSpacing: isLast(index) ? 0 : TSizes.timelineGap,
          ),
      ],
    );
  }
}
