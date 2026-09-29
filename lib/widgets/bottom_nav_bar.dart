import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

class BottomNavItem {
  final String label;
  final String iconAsset;

  const BottomNavItem({required this.label, required this.iconAsset});
}

class TBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      // Design has 14px bottom padding; on phones with a home indicator,
      // use the safe-area inset instead so the bar isn't doubly padded.
      padding: EdgeInsets.fromLTRB(
        8,
        10,
        8,
        math.max(14, MediaQuery.viewPaddingOf(context).bottom),
      ),
      child: Row(
        children: [
          for (final (index, item) in items.indexed)
            Expanded(
              child: _NavButton(
                item: item,
                isSelected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = isSelected ? colors.accent : colors.iconInactive;
    final labelColor = isSelected ? colors.accent : colors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.iconAsset,
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              item.label,
              style: TTextStyles.navLabel.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
