import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/dot_list_item.dart';
import '../models/issue.dart';

/// The steps of an issue: done (green), current (amber), upcoming (grey).
class IssueTimeline extends StatelessWidget {
  final Issue issue;

  const IssueTimeline({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // The latest completed step is the current one, unless the issue is
    // already closed.
    final currentIndex = issue.isOpen
        ? issue.timeline.lastIndexWhere((event) => event.isDone)
        : -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, event) in issue.timeline.indexed) ...[
          if (index > 0) const SizedBox(height: TSizes.timelineGap),
          DotListItem(
            title: _label(l10n, event.type),
            details: [
              if (event.date != null)
                TFormatters.dateTime(context, event.date!),
            ],
            dotColor: index == currentIndex
                ? colors.onWarningContainer
                : event.isDone
                ? colors.onSuccessContainer
                : colors.border,
          ),
        ],
      ],
    );
  }

  static String _label(AppLocalizations l10n, IssueEventType type) =>
      switch (type) {
        IssueEventType.submitted => l10n.timelineSubmitted,
        IssueEventType.assignedToEmployer => l10n.timelineAssignedToEmployer,
        IssueEventType.escalatedToEmbassy => l10n.timelineEscalatedToEmbassy,
        IssueEventType.resolved => l10n.timelineResolved,
      };
}
