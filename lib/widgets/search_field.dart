import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// A rounded search input with a magnifier icon.
class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyle = TTextStyles.bodySmall;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            width: TSizes.iconSm,
            height: TSizes.iconSm,
            colorFilter: ColorFilter.mode(colors.iconInactive, BlendMode.srcIn),
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: textStyle.copyWith(color: colors.textPrimary),
              cursorColor: colors.primary,
              // The Container above draws the box, so the field itself must
              // be bare. `.collapsed` only clears `border`; the app theme's
              // enabled/focused borders and fill would still apply, so turn
              // them off explicitly.
              decoration:
                  InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: textStyle.copyWith(color: colors.textSecondary),
                  ).copyWith(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
