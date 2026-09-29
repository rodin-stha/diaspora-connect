import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// Small bold blue text that acts as a button ("Mark all read", "Replace").
/// Greyed out when [onPressed] is null.
class LinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const LinkButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: colors.primary,
        disabledForegroundColor: colors.textSecondary,
        textStyle: TTextStyles.label,
      ),
      child: Text(label),
    );
  }
}
