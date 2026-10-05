import 'package:flutter/material.dart';

import '../theme/sizes.dart';

/// The main action button, showing a spinner while its action runs.
///
/// While [isLoading] it's disabled (grey, ignores taps) and keeps its size,
/// so nothing around it moves.
class LoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      // The label stays in the layout (just invisible) so the button keeps
      // its height and width when the spinner replaces it.
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Text(label),
          ),
          if (isLoading)
            // Builder gives a context inside the button, where
            // DefaultTextStyle holds the button's current text color (the
            // grey disabled one), so the spinner matches it.
            Builder(
              builder: (context) => SizedBox.square(
                dimension: TSizes.spinnerSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DefaultTextStyle.of(context).style.color,
                  semanticsLabel: label,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
