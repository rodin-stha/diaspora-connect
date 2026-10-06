import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'skeleton.dart';

/// A colored dot followed by a title and optional detail lines, used for
/// timelines and activity feeds.
///
/// Give it a [connectorColor] to draw a vertical line from the dot down to
/// the next item, like a stepper.
class DotListItem extends StatelessWidget {
  final String title;

  /// Smaller grey lines under the title (description, date…).
  final List<String> details;
  final Color dotColor;
  final double dotSize;

  /// Color of the line below the dot. Null means no line (e.g. last step).
  final Color? connectorColor;

  /// Empty space below the item. Kept inside the item (not as a SizedBox
  /// between items) so the connector line can run through it.
  final double bottomSpacing;

  const DotListItem({
    super.key,
    required this.title,
    this.details = const [],
    required this.dotColor,
    this.dotSize = TSizes.dotMd,
    this.connectorColor,
    this.bottomSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Semibold so each item's title stands out from its grey detail lines.
    final titleStyle = TTextStyles.body.copyWith(fontWeight: FontWeight.w600);

    // Height of the title's first line (font size × line height, scaled by
    // the user's text size setting). The dot is centered within it, so it
    // lines up with the title, not with the whole title + details block.
    final titleLineHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) *
        titleStyle.height!;

    final dot = SizedBox(
      height: titleLineHeight,
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/dot.svg',
          width: dotSize,
          height: dotSize,
          colorFilter: ColorFilter.mode(dotColor, BlendMode.srcIn),
        ),
      ),
    );

    // IntrinsicHeight makes the Row as tall as its tallest child (the text),
    // so the line below the dot can stretch to fill that height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              dot,
              if (connectorColor != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: TSizes.xs),
                    child: Container(
                      width: TSizes.connectorWidth,
                      decoration: BoxDecoration(
                        color: connectorColor,
                        borderRadius: BorderRadius.circular(
                          TSizes.connectorWidth,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: TSizes.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle.copyWith(color: colors.textPrimary),
                  ),
                  for (final detail in details) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stands in for a [DotListItem] while a feed loads: a grey dot, a title
/// bar and two detail bars. Wrap a group of them in one [Skeleton] so they
/// pulse together.
class DotListItemSkeleton extends StatelessWidget {
  const DotListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nudged down to sit level with the title bar, as the real dot does.
        Padding(
          padding: EdgeInsets.only(top: 3),
          child: SkeletonBox(
            width: TSizes.dotMd,
            height: TSizes.dotMd,
            radius: TSizes.dotMd,
          ),
        ),
        SizedBox(width: TSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              FractionallySizedBox(
                widthFactor: 0.55,
                child: SkeletonBox(height: 14),
              ),
              FractionallySizedBox(
                widthFactor: 0.85,
                child: SkeletonBox(height: 11),
              ),
              FractionallySizedBox(
                widthFactor: 0.3,
                child: SkeletonBox(height: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
