import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Paints the app's soft gradient image behind a screen.
///
/// Wrap a screen's [Scaffold] with it. Scaffolds inside are made transparent
/// so the image shows through, while this box itself stays opaque, so the
/// page underneath doesn't bleed through during push/pop transitions.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  static const _image = AssetImage('assets/images/bg-image.png');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        // Shown until the image has loaded.
        color: context.colors.background,
        image: const DecorationImage(image: _image, fit: BoxFit.cover),
      ),
      child: Theme(
        data: theme.copyWith(scaffoldBackgroundColor: Colors.transparent),
        child: child,
      ),
    );
  }
}
