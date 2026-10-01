import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_background.dart';
import '../../widgets/dot_list_item.dart';
import '../../widgets/link_button.dart';
import 'data/activity_provider.dart';
import 'models/activity.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final activities = ref.watch(activityProvider);
    final hasUnread = activities.any((activity) => !activity.isRead);

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.activityTitle,
                        style: TTextStyles.titleLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    LinkButton(
                      label: l10n.markAllRead,
                      // `read`, not `watch`: we only call a method here, we
                      // don't need to rebuild when the provider changes.
                      onPressed: hasUnread
                          ? () => ref
                                .read(activityProvider.notifier)
                                .markAllRead()
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.lg),
                Text(
                  l10n.activityDescription,
                  style: TTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: TSizes.lg),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      l10n.noActivity,
                      textAlign: TextAlign.center,
                      style: TTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                else
                  for (final (index, activity) in activities.indexed) ...[
                    if (index > 0) const SizedBox(height: TSizes.lg),
                    _ActivityItem(activity: activity),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Activity activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // Exhaustive: adding a new ActivityEvent subclass is a compile error
    // here until it's handled.
    final (title, detail) = switch (activity.event) {
      IssueSubmitted(:final reference, :final issueTitle) => (
        l10n.activityIssueSubmitted,
        '$reference · $issueTitle',
      ),
      MobileNumberUpdated(:final maskedNumber) => (
        l10n.activityMobileUpdated,
        l10n.activityMobileUpdatedDetail(maskedNumber),
      ),
      SignedIn() => (l10n.activitySignedIn, l10n.activitySignedInDetail),
      DocumentUploaded(:final documentName) => (
        l10n.activityDocumentUploaded,
        l10n.activityDocumentUploadedDetail(documentName),
      ),
      ProfileUpdated() => (
        l10n.activityProfileUpdated,
        l10n.activityProfileUpdatedDetail,
      ),
    };

    return DotListItem(
      title: title,
      details: [detail, TFormatters.dateTime(context, activity.date)],
      // Green = unread, grey = read
      dotColor: activity.isRead
          ? colors.iconInactive
          : colors.onSuccessContainer,
    );
  }
}
