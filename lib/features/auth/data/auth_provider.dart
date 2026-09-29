import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_provider.dart';

/// Where the user is in signing in.
class AuthState {
  final bool isSignedIn;

  /// The number a code was just sent to, while on the Verify screen.
  final String? pendingPhone;

  const AuthState({this.isSignedIn = false, this.pendingPhone});
}

/// Sign-in state for the whole app. The router watches it: signed-out users
/// only see the login screens, signed-in users never do.
///
/// Signed-in is saved on the device, so reopening the app skips login.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _signedInKey = 'signed_in';

  /// TEMPORARY, until the SMS/OTP API exists: every number "gets" a code,
  /// and this is the only code that verifies. Replace [sendCode] and
  /// [verifyCode] with API calls; nothing else needs to change.
  static const _devCode = '111111';

  @override
  AuthState build() => AuthState(
    isSignedIn:
        ref.read(sharedPreferencesProvider).getBool(_signedInKey) ?? false,
  );

  /// Sends a login code by SMS to [phone] (e.g. "+972 52 123 4567").
  Future<void> sendCode(String phone) async {
    // API call goes here.
    state = AuthState(pendingPhone: phone);
  }

  /// Checks the code the user typed. Returns false if it's wrong.
  Future<bool> verifyCode(String code) async {
    // API call goes here.
    if (code != _devCode) return false;
    await ref.read(sharedPreferencesProvider).setBool(_signedInKey, true);
    state = const AuthState(isSignedIn: true);
    return true;
  }

  Future<void> signOut() async {
    await ref.read(sharedPreferencesProvider).setBool(_signedInKey, false);
    state = const AuthState();
  }
}
