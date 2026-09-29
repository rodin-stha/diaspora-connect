import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import '../../widgets/issue_card.dart';
import '../issues/models/issue.dart';
import 'widgets/home_header.dart';
import 'widgets/report_issue_card.dart';

// Placeholder data until the issues API is connected.
const _sampleIssues = [
  Issue(
    title: 'Wage shortfall, October pay',
    reference: 'GN-2083-004512',
    dueInDays: 4,
    status: IssueStatus.inProgress,
  ),
  Issue(
    title: 'Permit renewal delayed',
    reference: 'GN-2083-004498',
    dueInDays: -1,
    status: IssueStatus.escalated,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status bar icons on the blue header
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                userName: 'Sita',
                location: "Kibbutz Afikim · Emek HaMa'ayanot Regional Council",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.pagePadding,
                  vertical: TSizes.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReportIssueCard(onTap: () {}),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    _SectionHeader(
                      title: l10n.myIssues,
                      actionLabel: l10n.viewAll,
                      onAction: () => context.go('/issues'),
                    ),
                    const SizedBox(height: TSizes.md),
                    for (final (index, issue) in _sampleIssues.indexed) ...[
                      if (index > 0) const SizedBox(height: TSizes.md),
                      IssueCard(issue: issue, onTap: () {}),
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
