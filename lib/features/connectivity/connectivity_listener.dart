import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/sizes.dart';
import '../../theme/text_styles.dart';
import 'data/connectivity_provider.dart';

/// SnackBars need a duration; this one should outlast any offline spell.
/// It's closed by code when the connection is back.
const _untilClosed = Duration(days: 365);

const _backOnlineDuration = Duration(seconds: 2);

/// Shows a small floating "No internet connection" message while the device
/// is offline. It can't be dismissed: it stays until the connection is
/// back, then says "Back online" for a moment.
///
/// It's a floating SnackBar, so Flutter places it above the bottom nav on
/// tab screens, above the home indicator elsewhere, and above the keyboard.
///
/// Wraps the whole app (MaterialApp's `builder`), so it shows on every
/// screen.
class ConnectivityListener extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityListener({super.key, required this.child});

  @override
  ConsumerState<ConnectivityListener> createState() =>
      _ConnectivityListenerState();
}

class _ConnectivityListenerState extends ConsumerState<ConnectivityListener> {
  bool _showingOffline = false;

  Future<void> _onConnectivityChanged() async {
    // Wait for the current frame to finish: at startup the check can answer
    // before the first screen (Scaffold) is built, and a SnackBar needs one
    // to show in.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    // Read it now, not before the wait: it may have changed since.
    final isOnline = ref.read(isOnlineProvider).value;
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final messenger = ScaffoldMessenger.of(context);

    if (isOnline == false && !_showingOffline) {
      _showingOffline = true;
      // SnackBars queue one at a time. Drop any others so this one shows
      // now, not after them.
      messenger.clearSnackBars();
      messenger.showSnackBar(
        _pill(
          message: l10n.noInternetConnection,
          icon: Icons.wifi_off_rounded,
          background: colors.inverseSurface,
          foreground: colors.onInverseSurface,
          duration: _untilClosed,
        ),
      );
    } else if (isOnline == true && _showingOffline) {
      _showingOffline = false;
      // Also drops messages queued behind it while offline (e.g. failed
      // requests): stale now that the connection is back.
      messenger.clearSnackBars();
      messenger.showSnackBar(
        _pill(
          message: l10n.backOnline,
          icon: Icons.wifi_rounded,
          background: colors.successContainer,
          foreground: colors.onSuccessContainer,
          duration: _backOnlineDuration,
        ),
      );
    }
  }

  SnackBar _pill({
    required String message,
    required IconData icon,
    required Color background,
    required Color foreground,
    required Duration duration,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      // Can't be swiped away.
      dismissDirection: DismissDirection.none,
      backgroundColor: background,
      elevation: 2,
      shape: const StadiumBorder(),
      margin: const EdgeInsets.fromLTRB(
        TSizes.pagePadding,
        0,
        TSizes.pagePadding,
        TSizes.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: TSizes.lg,
        vertical: TSizes.sm,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: TSizes.sm,
        children: [
          Icon(icon, size: TSizes.iconSm, color: foreground),
          Flexible(
            child: Text(
              message,
              style: TTextStyles.bodySmall.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Still checking (no value yet) shows nothing: no flash on every start.
    ref.listen(isOnlineProvider, (_, _) => _onConnectivityChanged());
    return widget.child;
  }
}
