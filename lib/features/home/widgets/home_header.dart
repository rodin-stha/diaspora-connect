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
    // The design has 22px above the greeting, measured below the status bar.
    final topPadding = MediaQuery.paddingOf(context).top + TSizes.pagePadding;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: TSizes.sm,
            children: [
              // Expanded takes the leftover width, pushing the toggle to the
              // right edge. A long name wraps instead of running under it.
              Expanded(
                child: Text(
                  l10n.greeting(userName),
                  style: TTextStyles.headline.copyWith(
                    color: colors.onPrimary,
                  ),
                ),
              ),
              const LanguageToggle(),
            ],
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
