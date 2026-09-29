import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';

class ReportIssueCard extends StatelessWidget {
  final VoidCallback onTap;

  const ReportIssueCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    return Material(
      color: colors.accent,
      borderRadius: BorderRadius.circular(TSizes.actionCardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/plus.svg',
                width: TSizes.iconLg,
                height: TSizes.iconLg,
                colorFilter: ColorFilter.mode(colors.onAccent, BlendMode.srcIn),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportIssueTitle,
                      style: TTextStyles.titleMedium.copyWith(
                        color: colors.onAccent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.reportIssueSubtitle,
                      style: TTextStyles.bodySmall.copyWith(
                        color: colors.onAccent,
                      ),
                    ),
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
