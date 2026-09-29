import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../models/issue.dart';

/// The steps of an issue: done (green), current (amber), upcoming (grey).
class IssueTimeline extends StatelessWidget {
  final Issue issue;

  const IssueTimeline({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final dateFormat = DateFormat(
      'd MMM, h:mm a',
      Localizations.localeOf(context).toLanguageTag(),
    );

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
          _TimelineStep(
            label: _label(l10n, event.type),
            date: event.date == null ? null : dateFormat.format(event.date!),
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

class _TimelineStep extends StatelessWidget {
  final String label;
  final String? date;
  final Color dotColor;

  const _TimelineStep({
    required this.label,
    required this.date,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = TTextStyles.body;

    // Height of the label's first line (font size × line height, scaled by
    // the user's text size setting). The dot is centered within it, so it
    // lines up with the label, not with the label + date block.
    final labelLineHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize!) *
        labelStyle.height!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: labelLineHeight,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/dot.svg',
              width: TSizes.dotSize,
              height: TSizes.dotSize,
              colorFilter: ColorFilter.mode(dotColor, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: labelStyle.copyWith(color: colors.textPrimary),
              ),
              if (date != null) ...[
                const SizedBox(height: 2),
                Text(
                  date!,
                  style: TTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
