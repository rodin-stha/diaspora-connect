import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A full-width tappable row in a settings-style list, e.g.
/// "Personal details ›".
class MenuRow extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  /// Red text for actions like "Log out".
  final bool isDestructive;
  final bool showChevron;

  /// Line under the row, separating it from the next one.
  final bool showDivider;

  const MenuRow({
    super.key,
    required this.title,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: TSizes.menuRowPadding),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              )
            : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TTextStyles.body.copyWith(
                  color: isDestructive ? colors.accent : colors.textPrimary,
                ),
              ),
            ),
            if (showChevron)
              SvgPicture.asset(
                'assets/icons/chevron_right.svg',
                width: TSizes.iconSm,
                height: TSizes.iconSm,
                colorFilter: ColorFilter.mode(
                  colors.iconInactive,
                  BlendMode.srcIn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
