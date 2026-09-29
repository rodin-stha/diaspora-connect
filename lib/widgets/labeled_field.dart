import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A small label above any form input (text field, dropdown…), with an
/// optional error message below it.
///
/// Has a minimum height so an error message can appear under the input
/// without pushing the rest of the form down much.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  /// Adds a red "*" after the label.
  final bool isRequired;

  /// Shown under [child], aligned with the label.
  final String? errorText;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelStyle = TTextStyles.label.copyWith(color: colors.textSecondary);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TSizes.fieldMinHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
              ],
            ),
            style: labelStyle,
            // Screen readers would say "star"; say "required" instead.
            semanticsLabel: isRequired
                ? '$label, ${AppLocalizations.of(context).requiredField}'
                : null,
          ),
          const SizedBox(height: 6),
          child,
          if (errorText != null) FieldErrorText(errorText!),
        ],
      ),
    );
  }
}

/// A validation message under a form input, slightly indented from the
/// input's left edge.
class FieldErrorText extends StatelessWidget {
  final String message;

  const FieldErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: TSizes.xs, top: TSizes.xs),
      child: Text(
        message,
        style: TTextStyles.bodySmall.copyWith(
          color: context.colors.onErrorContainer,
        ),
      ),
    );
  }
}
