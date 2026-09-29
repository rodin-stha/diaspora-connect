import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/sizes.dart';

/// A progress bar split into equal segments, one per step, with the first
/// [completed] filled in (onboarding's "step 2 of 3").
class SegmentedProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const SegmentedProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      value: '$completed / $total',
      child: Row(
        spacing: 6,
        children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < completed ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(TSizes.pillRadius),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
