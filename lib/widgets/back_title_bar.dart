import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// Empty space on the left of the chevron inside back.svg (path starts at
/// x = 8.25, minus half the 1.83 stroke). Removing it lines the chevron up
/// with the page content below.
const double _chevronLeftInset = 7.33;

/// Gap between the icon box and the title in the design.
const double _titleGap = 14;

/// A back chevron followed by a page title, for pages pushed on top of a tab.
/// Without a [title], just the chevron.
class BackTitleBar extends StatelessWidget {
  final String? title;

  /// Where to go when there's nothing to pop, e.g. the page was opened
  /// directly from a deep link.
  final String fallbackLocation;

  const BackTitleBar({
    super.key,
    this.title,
    required this.fallbackLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(fallbackLocation),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          // Keep the icon at its design size, with no extra padding.
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Transform.translate(
            // Moves the drawing only; layout and the title don't shift.
            offset: const Offset(-_chevronLeftInset, 0),
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              colorFilter: ColorFilter.mode(
                colors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (title != null) ...[
          // The chevron is drawn shifted left but its box isn't, which adds
          // the same amount of empty space on its right. Take it back here so
          // the visible gap matches the design.
          const SizedBox(width: _titleGap - _chevronLeftInset),
          Expanded(
            child: Text(
              title!,
              style: TTextStyles.appBarTitle.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
