import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// Something attached to a form ("Location pinned", a voice note): a
/// leading icon or button, a title and subtitle, and ✕ to remove it.
class AttachmentRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;

  /// Tapping the row (e.g. to change the pin). Null makes it not tappable.
  final VoidCallback? onTap;
  final VoidCallback onRemove;

  const AttachmentRow({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.inputRadius),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          child: Row(
            spacing: 10,
            children: [
              leading,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TTextStyles.bodyCompact.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(Icons.close, size: TSizes.iconSm),
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
