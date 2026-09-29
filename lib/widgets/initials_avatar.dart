import 'package:flutter/material.dart';

import '../theme/text_styles.dart';

/// A circle showing a person's initials, e.g. "SS" for Sita Kumari Shrestha.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const InitialsAvatar({
    super.key,
    required this.name,
    required this.size,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// First letter of the first and last names: "Sita Kumari Shrestha" → "SS",
  /// "Sita" → "S".
  ///
  /// Uses `.characters` (whole visible characters), not `name[0]` (a UTF-16
  /// unit), so Devanagari like "सी" isn't cut in half.
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      // Decorative: the full name is shown next to it.
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        padding: EdgeInsets.all(size * 0.15),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        // Shrinks the initials if the user's text size setting is very large,
        // instead of overflowing the circle.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            initialsOf(name),
            style: TTextStyles.titleLarge.copyWith(color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
