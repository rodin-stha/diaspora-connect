import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';
import 'link_button.dart';
import 'skeleton.dart';

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

    return _DocumentRowFrame(
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

/// Placeholder for a [DocumentRow] while the list loads. Put it inside a
/// [Skeleton] so it pulses.
class DocumentRowSkeleton extends StatelessWidget {
  const DocumentRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final nameStyle = TTextStyles.bodyCompact;

    return _DocumentRowFrame(
      // As tall as one line of the name, so the row doesn't change height
      // when the real one replaces it.
      child: SizedBox(
        height: nameStyle.fontSize! * nameStyle.height!,
        child: const Row(
          spacing: 10,
          children: [
            SkeletonBox(width: TSizes.iconSm, height: TSizes.iconSm),
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.5,
                child: SkeletonBox(height: 12),
              ),
            ),
            SkeletonBox(width: 32, height: 12),
          ],
        ),
      ),
    );
  }
}

/// The bordered card shared by [DocumentRow] and its skeleton, so the two
/// always match.
class _DocumentRowFrame extends StatelessWidget {
  final Widget child;

  const _DocumentRowFrame({required this.child});

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
      child: child,
    );
  }
}
