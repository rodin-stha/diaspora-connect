import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'link_button.dart';

/// Shown in place of content that failed to load: what went wrong and a
/// Retry link.
class LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LoadError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xl),
      child: Column(
        spacing: TSizes.sm,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TTextStyles.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          LinkButton(
            label: AppLocalizations.of(context).retry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
