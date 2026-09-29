import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A colored dot followed by a title and optional detail lines, used for
/// timelines and activity feeds.
class DotListItem extends StatelessWidget {
  final String title;

  /// Smaller grey lines under the title (description, date…).
  final List<String> details;
  final Color dotColor;
  final double dotSize;

  const DotListItem({
    super.key,
    required this.title,
    this.details = const [],
    required this.dotColor,
    this.dotSize = TSizes.dotMd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleStyle = TTextStyles.body;

    // Height of the title's first line (font size × line height, scaled by
    // the user's text size setting). The dot is centered within it, so it
    // lines up with the title, not with the whole title + details block.
    final titleLineHeight =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) *
        titleStyle.height!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: titleLineHeight,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/dot.svg',
              width: dotSize,
              height: dotSize,
              colorFilter: ColorFilter.mode(dotColor, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
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
      ],
    );
  }
}
