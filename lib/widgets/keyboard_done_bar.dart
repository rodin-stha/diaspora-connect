import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../theme/sizes.dart';
import '../theme/text_styles.dart';

/// On iOS, a bar with "Done" right above the keyboard that closes it.
///
/// iOS number and phone keyboards have no Return key, so without this
/// there's no way to put them away. Android keyboards have their own hide
/// button (and the back gesture), so it's iOS only, like native iOS apps.
///
/// Wraps the whole app (MaterialApp's `builder`), so it works for every
/// text field, including those in dialogs.
class KeyboardDoneBar extends StatelessWidget {
  final Widget child;

  const KeyboardDoneBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final showBar = isIOS && keyboardHeight > 0;

    // Always the same Stack > MediaQuery > child shape, bar or not. If it
    // changed when the keyboard opens, Flutter would rebuild the whole app
    // below it from scratch: screens, navigation and the focused field.
    return Stack(
      fit: StackFit.expand,
      children: [
        // Tell the app the keyboard is taller by the bar's height, so
        // screens shrink to leave room and scroll the focused field above
        // the bar, not behind it.
        MediaQuery(
          data: showBar
              ? mediaQuery.copyWith(
                  viewInsets: mediaQuery.viewInsets.copyWith(
                    bottom: keyboardHeight + TSizes.keyboardBarHeight,
                  ),
                )
              : mediaQuery,
          child: child,
        ),
        // Sits on the keyboard's top edge, and follows it as it slides.
        if (showBar)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: const _Bar(),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      child: Container(
        height: TSizes.keyboardBarHeight,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.border)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: TSizes.xs),
        child: TextButton(
          // Unfocusing the field closes the keyboard (it slides down).
          onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          child: Text(
            AppLocalizations.of(context).done,
            style: TTextStyles.titleSmall,
          ),
        ),
      ),
    );
  }
}
