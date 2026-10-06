import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'link_button.dart';

/// "Nothing here yet": a large muted icon, a message, and optionally a link
/// to the action that fills the screen ("Report a new issue").
class EmptyState extends StatelessWidget {
  final String iconAsset;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.iconAsset,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = actionLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        spacing: TSizes.sm,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: TSizes.iconEmptyState,
            height: TSizes.iconEmptyState,
            colorFilter: ColorFilter.mode(colors.iconInactive, BlendMode.srcIn),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          if (label != null) LinkButton(label: label, onPressed: onAction),
        ],
      ),
    );
  }
}
