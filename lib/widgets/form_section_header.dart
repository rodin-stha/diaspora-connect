import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A small uppercase heading splitting a form into sections ("YOUR HOME IN
/// ISRAEL"), with a divider above it by default.
class FormSectionHeader extends StatelessWidget {
  final String title;
  final bool showDivider;

  /// Adds a red "*" after the title, like [LabeledField]. For a section
  /// that starts with an input without its own label (e.g. a row of
  /// chips), so the heading is its label.
  final bool isRequired;

  const FormSectionHeader({
    super.key,
    required this.title,
    this.showDivider = true,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TSizes.formGap,
      children: [
        if (showDivider) Divider(height: 1, thickness: 1, color: colors.border),
        Text.rich(
          TextSpan(
            // Uppercase is styling (like CSS text-transform); Devanagari
            // has no case and is unaffected.
            text: title.toUpperCase(),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colors.onErrorContainer),
                ),
            ],
          ),
          style: TTextStyles.caption.copyWith(color: colors.textSecondary),
          // Screen readers would say "star"; say "required" instead.
          semanticsLabel: isRequired
              ? '$title, ${AppLocalizations.of(context).requiredField}'
              : null,
        ),
      ],
    );
  }
}
