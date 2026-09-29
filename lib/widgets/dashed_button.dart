import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'dashed_border.dart';

/// A full-width button with a dashed outline, for "add something" actions
/// ("+ Upload new document").
class DashedButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;

  const DashedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset = 'assets/icons/plus_small.svg',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderRadius = BorderRadius.circular(TSizes.inputRadius);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: DashedBorder(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: TSizes.sm,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: TSizes.iconSm,
                  height: TSizes.iconSm,
                  colorFilter: ColorFilter.mode(
                    colors.iconDefault,
                    BlendMode.srcIn,
                  ),
                ),
                Flexible(
                  child: Text(
                    label,
                    style: TTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
