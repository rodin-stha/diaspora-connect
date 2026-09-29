import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A small uppercase heading splitting a form into sections ("YOUR HOME IN
/// ISRAEL"), with a divider above it by default.
class FormSectionHeader extends StatelessWidget {
  final String title;
  final bool showDivider;

  const FormSectionHeader({
    super.key,
    required this.title,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TSizes.formGap,
      children: [
        if (showDivider) Divider(height: 1, thickness: 1, color: colors.border),
        Text(
          // Uppercase is styling (like CSS text-transform); Devanagari has
          // no case and is unaffected.
          title.toUpperCase(),
          style: TTextStyles.caption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
