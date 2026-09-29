import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// The Figma "Toggle Switch": 40×24 pill, blue when on, grey when off, with
/// a white knob that slides across.
///
/// Drawn in code (not the Figma SVGs) so it animates, follows the theme and
/// is announced as a switch by screen readers.
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  static const double _width = 40;
  static const double _height = 24;
  static const double _knobInset = 2;
  static const _duration = Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: _duration,
          width: _width,
          height: _height,
          padding: const EdgeInsets.all(_knobInset),
          decoration: BoxDecoration(
            color: value ? colors.primary : colors.border,
            borderRadius: BorderRadius.circular(_height / 2),
          ),
          child: AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: _height - 2 * _knobInset,
              height: _height - 2 * _knobInset,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
