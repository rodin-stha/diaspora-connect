import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A big, solid-colored button: an icon above a label, centered.
///
/// Without an [iconAsset], the label alone fills the tile in large type
/// (e.g. "SOS").
class ActionTile extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final Color color;

  /// Icon and text color on [color].
  final Color onColor;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.label,
    this.iconAsset,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconAsset = this.iconAsset;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(TSizes.actionCardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          // A minimum, not a fixed height: longer Nepali labels or a larger
          // system font can wrap and grow the tile instead of overflowing.
          constraints: const BoxConstraints(
            minHeight: TSizes.actionTileMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: TSizes.sm,
              children: [
                if (iconAsset != null)
                  // No width/height: the SVG keeps its designed size.
                  SvgPicture.asset(
                    iconAsset,
                    colorFilter: ColorFilter.mode(onColor, BlendMode.srcIn),
                  ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style:
                      (iconAsset == null
                              ? TTextStyles.tileDisplay
                              : TTextStyles.tileLabel)
                          .copyWith(color: onColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
