import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_provider.dart';

/// Where the user is in signing in.
class AuthState {
  final bool isSignedIn;

  /// Whether the user has filled in their profile (onboarding steps 1–3).
  /// Signed-in users who haven't are kept on the onboarding screens.
  final bool isOnboarded;

  /// The number a code was just sent to, while on the Verify screen.
  final String? pendingPhone;

  const AuthState({
    this.isSignedIn = false,
    this.isOnboarded = false,
    this.pendingPhone,
  });
}

/// Sign-in state for the whole app. The router watches it: signed-out users
/// only see the login screens, signed-in users never do.
///
/// Signed-in and onboarded are saved on the device, so reopening the app
/// skips login and onboarding.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _signedInKey = 'signed_in';
  static const _onboardedKey = 'onboarded';

  /// TEMPORARY, until the SMS/OTP API exists: every number "gets" a code,
  /// and this is the only code that verifies. Replace [sendCode] and
  /// [verifyCode] with API calls; nothing else needs to change.
  static const _devCode = '111111';

  @override
  AuthState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final isSignedIn = prefs.getBool(_signedInKey) ?? false;
    return AuthState(
      isSignedIn: isSignedIn,
      // Onboarding is decided at login (see [verifyCode]), which always
      // saves this flag. A session with no flag saved started before
      // onboarding existed, so its profile is already filled in.
      isOnboarded: prefs.getBool(_onboardedKey) ?? isSignedIn,
    );
  }

  /// TEMPORARY: kept on the device, and kept after logging out. Once the
  /// API exists, verifying the code should return whether this account
  /// already has a profile.
  bool get _isOnboarded =>
      ref.read(sharedPreferencesProvider).getBool(_onboardedKey) ?? false;

  /// Sends a login code by SMS to [phone] (e.g. "+972 52 123 4567").
  Future<void> sendCode(String phone) async {
    // API call goes here.
    state = AuthState(isOnboarded: _isOnboarded, pendingPhone: phone);
  }

  /// Checks the code the user typed. Returns false if it's wrong.
  Future<bool> verifyCode(String code) async {
    // API call goes here.
    if (code != _devCode) return false;
    final prefs = ref.read(sharedPreferencesProvider);
    final isOnboarded = _isOnboarded;
    // Save both, so closing the app mid-onboarding resumes onboarding on
    // the next launch instead of skipping it.
    await prefs.setBool(_onboardedKey, isOnboarded);
    await prefs.setBool(_signedInKey, true);
    state = AuthState(isSignedIn: true, isOnboarded: isOnboarded);
    return true;
  }

  /// Called after the last onboarding step is saved.
  Future<void> completeOnboarding() async {
    await ref.read(sharedPreferencesProvider).setBool(_onboardedKey, true);
    state = const AuthState(isSignedIn: true, isOnboarded: true);
  }

  Future<void> signOut() async {
    await ref.read(sharedPreferencesProvider).setBool(_signedInKey, false);
    state = AuthState(isOnboarded: _isOnboarded);
  }
}
