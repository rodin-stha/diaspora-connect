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
import '../../widgets/skeleton.dart';
import 'data/activity_provider.dart';
import 'models/activity.dart';

// Placeholder items while the feed loads: enough to fill most of the
// screen, like a real feed would.
const _skeletonCount = 5;

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final activitiesAsync = ref.watch(activityProvider);
    // Empty while loading, so "Mark all read" stays disabled until then.
    final activities = activitiesAsync.value ?? const <Activity>[];
    final hasUnread = activities.any((activity) => !activity.isRead);

    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AppBackground(
        child: Scaffold(
          // Pull down to fetch the latest. `refresh` returns the new fetch's
          // Future, so the spinner stays until it completes.
          body: RefreshIndicator(
            onRefresh: () => ref.refresh(activityProvider.future),
            child: SingleChildScrollView(
              // Lets the pull work even when the list is too short to scroll.
              physics: const AlwaysScrollableScrollPhysics(),
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
                  activitiesAsync.when(
                    data: (activities) => activities.isEmpty
                        ? _CenteredMessage(l10n.noActivity)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: TSizes.lg,
                            children: [
                              for (final activity in activities)
                                _ActivityItem(activity: activity),
                            ],
                          ),
                    // Placeholder items in the shape of the real feed, so
                    // nothing jumps when it arrives.
                    loading: () => Skeleton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: TSizes.lg,
                        children: [
                          for (var i = 0; i < _skeletonCount; i++)
                            const DotListItemSkeleton(),
                        ],
                      ),
                    ),
                    error: (error, _) => Column(
                      spacing: TSizes.sm,
                      children: [
                        _CenteredMessage(l10n.errorLoadActivity),
                        LinkButton(
                          label: l10n.retry,
                          onPressed: () => ref.invalidate(activityProvider),
                        ),
                      ],
                    ),
                    // After an error, Retry shows the spinner. With a list on screen,
                    // pull-to-refresh keeps it (the pull has its own spinner).
                    skipLoadingOnRefresh: !activitiesAsync.hasError,
                  ),
                ],
              ),
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
      PersonalDetailsSaved() => (
        l10n.activityProfileUpdated,
        l10n.activityPersonalDetailsSavedDetail,
      ),
      AccountCreated() => (
        l10n.activityAccountCreated,
        l10n.activityAccountCreatedDetail,
      ),
      OtherActivity(:final description) => (description, null),
    };

    return DotListItem(
      title: title,
      details: [?detail, TFormatters.dateTime(context, activity.date)],
      // Green = unread, grey = read
      dotColor: activity.isRead
          ? colors.iconInactive
          : colors.onSuccessContainer,
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;

  const _CenteredMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TTextStyles.body.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}
