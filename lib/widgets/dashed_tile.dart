import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'dashed_border.dart';

/// A small dashed tile with an icon above a label ("📷 Photo"), for
/// optional "add something" actions laid out side by side.
class DashedTile extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onTap;

  const DashedTile({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        child: DashedBorder(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              spacing: 6,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: TSizes.iconXs,
                  height: TSizes.iconXs,
                  colorFilter: ColorFilter.mode(
                    colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TTextStyles.tiny.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
