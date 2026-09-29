import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// The Figma "Chip" component: solid blue when selected, outlined otherwise.
class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.surface,
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
            ),
            borderRadius: BorderRadius.circular(TSizes.pillRadius),
          ),
          child: Text(
            label,
            style: TTextStyles.chipLabel.copyWith(
              color: isSelected ? colors.onPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
