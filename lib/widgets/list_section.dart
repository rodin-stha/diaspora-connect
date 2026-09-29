import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';

/// A small uppercase heading followed by its rows, on settings-style screens
/// (Profile, Notification settings).
class ListSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// Space between the heading and the first row.
  final double titleGap;

  const ListSection({
    super.key,
    required this.title,
    required this.children,
    this.titleGap = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          // Uppercase is styling (like CSS text-transform), so the ARB file
          // keeps normal case. Devanagari has no case and is unaffected.
          title.toUpperCase(),
          style: TTextStyles.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: titleGap),
        ...children,
      ],
    );
  }
}
