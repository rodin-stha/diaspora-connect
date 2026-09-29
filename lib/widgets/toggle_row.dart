import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'toggle_switch.dart';

/// A settings row with a label and an on/off switch. Tapping anywhere on the
/// row flips the switch.
class ToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Line under the row, separating it from the next one.
  final bool showDivider;

  const ToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // One screen-reader element: "SMS alerts, switch, on".
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                  style: TTextStyles.body.copyWith(color: colors.textPrimary),
                ),
              ),
              ToggleSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
