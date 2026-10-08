import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/app_background.dart';
import '../../widgets/issue_card.dart';
import '../../widgets/load_error.dart';
import '../../widgets/skeleton.dart';
import '../announcements/widgets/announcements_section.dart';
import '../issues/data/issues_provider.dart';
import '../notification_settings/data/notification_settings_provider.dart';
import '../notification_settings/models/notification_setting.dart';
import '../profile/data/user_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/report_issue_card.dart';

// Home previews the latest issues; the full list is on the Issues tab.
const _maxPreviewIssues = 5;

// How many placeholder cards to show while loading. The real count isn't
// known yet; a few look like "a list" without overpromising.
const _skeletonCount = 3;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final issuesAsync = ref.watch(issuesProvider);
    // `select`: rebuild only when this one switch changes, not the others.
    final showAnnouncements = ref.watch(
      notificationSettingsProvider.select(
        (settings) => settings[NotificationSetting.embassyAnnouncements]!,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the blue header
      value: SystemUiOverlayStyle.light,
      child: AppBackground(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  userName: user.givenName,
                  location: user.location,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TSizes.pagePadding,
                    vertical: TSizes.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReportIssueCard(
                        onTap: () => context.push('/report-issue'),
                      ),
                      const SizedBox(height: TSizes.spaceBtwSections),
                      // Off: not built, so not fetched either.
                      if (showAnnouncements) const AnnouncementsSection(),
                      _SectionHeader(
                        title: l10n.myIssues,
                        actionLabel: l10n.viewAll,
                        onAction: () => context.go('/issues'),
                      ),
                      const SizedBox(height: TSizes.md),
                      issuesAsync.when(
                        data: (issues) {
                          // The API sends them newest first.
                          final latestIssues = issues.take(_maxPreviewIssues);
                          if (latestIssues.isEmpty) {
                            return Text(
                              l10n.noIssuesYet,
                              style: TTextStyles.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: TSizes.md,
                            children: [
                              for (final issue in latestIssues)
                                IssueCard(
                                  issue: issue,
                                  onTap: () => context.push(
                                    '/issues/${issue.reference}',
                                  ),
                                ),
                            ],
                          );
                        },
                        // Placeholder cards in the shape of the real ones, so
                        // nothing jumps when the issues arrive.
                        loading: () => Skeleton(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: TSizes.md,
                            children: [
                              for (var i = 0; i < _skeletonCount; i++)
                                const IssueCardSkeleton(),
                            ],
                          ),
                        ),
                        error: (error, _) => LoadError(
                          message: l10n.errorLoadIssues,
                          onRetry: () => ref.invalidate(issuesProvider),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TTextStyles.titleSmall.copyWith(color: colors.textPrimary),
        ),
        GestureDetector(
          onTap: onAction,
          behavior: HitTestBehavior.opaque,
          child: Text(
            actionLabel,
            style: TTextStyles.label.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }
}
