import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'dashed_border.dart';

/// A dashed tile with an icon above a label ("📷 Photo"), for "add
/// something" actions.
///
/// The default is compact, for several small tiles side by side (Report an
/// issue's evidence). [DashedTile.large] is roomier, for upload slots
/// (onboarding's passport and work permit).
class DashedTile extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback? onTap;

  /// Outlines the tile in the error color, e.g. a required upload is missing.
  final bool hasError;
  final bool _large;

  const DashedTile({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
    this.hasError = false,
  }) : _large = false;

  const DashedTile.large({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
    this.hasError = false,
  }) : _large = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        child: DashedBorder(
          color: hasError ? colors.onErrorContainer : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 6,
              vertical: _large ? 18 : 12,
            ),
            child: Column(
              spacing: 6,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: _large ? TSizes.iconSm : TSizes.iconXs,
                  height: _large ? TSizes.iconSm : TSizes.iconXs,
                  colorFilter: ColorFilter.mode(
                    colors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: (_large ? TTextStyles.bodySmall : TTextStyles.tiny)
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
