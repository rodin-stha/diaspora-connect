import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../../theme/text_styles.dart';
import '../../../widgets/language_toggle.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String location;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    // Design uses 54px top padding, which sits just below the status bar.
    final topPadding = math.max(54.0, MediaQuery.paddingOf(context).top + 8);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        TSizes.pagePadding,
        topPadding,
        TSizes.pagePadding,
        TSizes.pagePadding,
      ),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(TSizes.headerRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded takes the leftover width, pushing the toggle to the
              // right edge. The ellipsis guards against a long translated name.
              Expanded(
                child: Text(
                  l10n.appName,
                  style: TTextStyles.logo.copyWith(color: colors.onPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: TSizes.sm),
              const LanguageToggle(),
            ],
          ),
          const SizedBox(height: TSizes.lg),
          Text(
            l10n.greeting(userName),
            style: TTextStyles.headline.copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            location,
            style: TTextStyles.bodySmall.copyWith(color: colors.onPrimary),
          ),
        ],
      ),
    );
  }
}
