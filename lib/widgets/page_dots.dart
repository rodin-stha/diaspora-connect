import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

/// A row of dots showing which page of a carousel is on screen. The
/// current one is a wider pill.
class PageDots extends StatelessWidget {
  final int count;
  final int current;

  const PageDots({super.key, required this.count, required this.current});

  static const _dotSize = 6.0;
  static const _activeWidth = 16.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Screen readers announce the page itself; the dots are decoration.
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: TSizes.xs,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == current ? _activeWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: i == current ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(TSizes.pillRadius),
              ),
            ),
        ],
      ),
    );
  }
}
