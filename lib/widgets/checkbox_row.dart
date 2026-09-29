import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A checkbox with a label next to it ("I consent to …"). Tapping the label
/// toggles it too.
class CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Draws the unchecked box in the error color, for a required box that
  /// was left empty.
  final bool hasError;

  const CheckboxRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  static const double _boxSize = 18;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // MergeSemantics: screen readers announce "checkbox, checked, I consent
    // to …" as one item instead of the box and text separately.
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(TSizes.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
          child: Row(
            spacing: 10,
            children: [
              // Checkbox reserves a 48px tap area by default; the whole row
              // is tappable here, so shrink it to the drawn box.
              SizedBox.square(
                dimension: _boxSize,
                child: Checkbox(
                  value: value,
                  onChanged: (checked) => onChanged(checked ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: colors.primary,
                  checkColor: colors.onPrimary,
                  side: BorderSide(
                    color: hasError ? colors.onErrorContainer : colors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  label,
                  style: TTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
