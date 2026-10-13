import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../utils/formatters.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/dot_list_item.dart';
import '../../../widgets/image_viewer.dart';
import '../../../widgets/network_photo.dart';
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

    String? noteOf(StatusChange change) {
      final body = change.body?.trim() ?? '';
      return body.isEmpty ? null : body;
    }

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
            // What the case worker asked for, if they wrote anything.
            note: change.status == IssueStatus.needsInfo
                ? noteOf(change)
                : null,
            footer: switch (change.answer) {
              final answer? => _Answer(answer: answer),
              null => null,
            },
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

/// The user's reply under a case worker's question: "Your reply", the
/// text, and a small preview of the photo that opens full screen.
class _Answer extends StatelessWidget {
  final IssueAnswer answer;

  const _Answer({required this.answer});

  static const double _photoSize = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final body = answer.body?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          l10n.replyLabel,
          style: TTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        if (body.isNotEmpty)
          Text(
            body,
            style: TTextStyles.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (answer.photoUrl case final url?)
          Padding(
            padding: const EdgeInsets.only(top: TSizes.xs),
            child: Semantics(
              button: true,
              label: l10n.viewPhoto,
              child: GestureDetector(
                onTap: () => showImageViewer(context, url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TSizes.inputRadius),
                  child: SizedBox.square(
                    dimension: _photoSize,
                    child: NetworkPhoto(url: url),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
