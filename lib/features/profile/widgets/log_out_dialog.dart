import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/colors.dart';
import '../../../theme/sizes.dart';
import '../../auth/data/auth_provider.dart';

/// "Log out?" with Cancel and Log out. Asks first, so an accidental tap
/// doesn't sign the user out.
///
/// After Log out it stays open with a spinner until the server has ended
/// the session. Then the router's redirect shows the login screen, which
/// also removes this dialog.
class LogOutDialog extends ConsumerStatefulWidget {
  const LogOutDialog({super.key});

  @override
  ConsumerState<LogOutDialog> createState() => _LogOutDialogState();
}

class _LogOutDialogState extends ConsumerState<LogOutDialog> {
  bool _loggingOut = false;

  Future<void> _logOut() async {
    setState(() => _loggingOut = true);
    await ref.read(authProvider.notifier).signOut();
    // Usually already gone (the redirect to login removes it); close it
    // ourselves only if it's still showing.
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    // While logging out, the Back button / gesture can't close it either.
    return PopScope(
      canPop: !_loggingOut,
      child: AlertDialog(
        title: Text(l10n.logOutConfirmTitle),
        content: Text(l10n.logOutConfirmBody),
        actions: [
          TextButton(
            // Null disables it: too late to cancel once the request is sent.
            onPressed: _loggingOut ? null : () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: _loggingOut ? null : _logOut,
            // Red, like the Log out button: it's the destructive choice.
            style: TextButton.styleFrom(foregroundColor: colors.accent),
            child: _loggingOut
                ? SizedBox.square(
                    dimension: TSizes.iconSm,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  )
                : Text(l10n.logOut),
          ),
        ],
      ),
    );
  }
}
