import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/locale_provider.dart';
import 'auth_repository.dart';

/// Where the user is in signing in.
class AuthState {
  final bool isSignedIn;

  /// Whether the user has filled in their profile (onboarding steps 1–3).
  /// Signed-in users who haven't are kept on the onboarding screens.
  final bool isOnboarded;

  /// The number a code was just sent to, while on the Verify screen.
  final String? pendingPhone;

  final int? otpExpireTime;

  const AuthState({
    this.isSignedIn = false,
    this.isOnboarded = false,
    this.pendingPhone,
    this.otpExpireTime,
  });
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _isRegister = 'signed_in';
  static const _onboardedKey = 'onboarded';

  @override
  AuthState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final isSignedIn = prefs.getBool(_isRegister) ?? false;
    return AuthState(
      isSignedIn: isSignedIn,
      isOnboarded: prefs.getBool(_onboardedKey) ?? isSignedIn,
    );
  }

  bool get _isOnboarded =>
      ref.read(sharedPreferencesProvider).getBool(_onboardedKey) ?? false;

  Future<void> register(String phone) async {
    final response = await ref.read(authRepositoryProvider).register(phone);
    state = AuthState(
      isOnboarded: _isOnboarded,
      pendingPhone: phone,
      otpExpireTime: response.expiresIn,
    );
  }

  /// Checks the code the user typed. Returns false if it's wrong.
  Future<void> verifyCode(String phoneNumber, String code) async {
    await ref.read(authRepositoryProvider).verifyCode(phoneNumber, code);
    final prefs = ref.read(sharedPreferencesProvider);
    final isOnboarded = _isOnboarded;
    await prefs.setBool(_onboardedKey, isOnboarded);
    await prefs.setBool(_isRegister, true);
    state = AuthState(isSignedIn: true, isOnboarded: isOnboarded);
  }

  /// Called after the last onboarding step is saved.
  Future<void> completeOnboarding() async {
    await ref.read(sharedPreferencesProvider).setBool(_onboardedKey, true);
    state = const AuthState(isSignedIn: true, isOnboarded: true);
  }

  Future<void> signOut() async {
    await ref.read(sharedPreferencesProvider).setBool(_isRegister, false);
    state = AuthState(isOnboarded: _isOnboarded);
  }
}
