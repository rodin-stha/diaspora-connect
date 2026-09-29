import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'link_button.dart';

/// A document in a list: file icon, name, and an action on the right
/// ("Replace" when uploaded, "Upload" when missing).
class DocumentRow extends StatelessWidget {
  final String name;
  final String actionLabel;
  final VoidCallback? onAction;

  const DocumentRow({
    super.key,
    required this.name,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
      ),
      child: Row(
        spacing: 10,
        children: [
          SvgPicture.asset(
            'assets/icons/document.svg',
            width: TSizes.iconSm,
            height: TSizes.iconSm,
            colorFilter: ColorFilter.mode(
              colors.onInfoContainer,
              BlendMode.srcIn,
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: TTextStyles.bodyCompact.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          LinkButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
