import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/issue_card.dart';
import '../issues/data/issues_provider.dart';
import '../profile/data/user_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/report_issue_card.dart';

// Home previews a few open issues; the full list is on the Issues tab.
const _maxPreviewIssues = 2;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    // Home just shows nothing until issues arrive; the Issues tab has the
    // loading and error states.
    final openIssues = (ref.watch(issuesProvider).value ?? const [])
        .where((issue) => issue.isOpen)
        .take(_maxPreviewIssues);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the blue header
      value: SystemUiOverlayStyle.light,
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
                    _SectionHeader(
                      title: l10n.myIssues,
                      actionLabel: l10n.viewAll,
                      onAction: () => context.go('/issues'),
                    ),
                    const SizedBox(height: TSizes.md),
                    for (final (index, issue) in openIssues.indexed) ...[
                      if (index > 0) const SizedBox(height: TSizes.md),
                      IssueCard(
                        issue: issue,
                        onTap: () => context.push('/issues/${issue.id}'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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
