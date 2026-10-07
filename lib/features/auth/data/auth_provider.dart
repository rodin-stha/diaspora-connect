import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/api/api_exception.dart';

import 'auth_repository.dart';
import 'token_storage.dart';

/// Where the user is in signing in.
class AuthState {
  final bool isSignedIn;

  /// The number a code was just sent to, while on the Verify screen.
  final String? pendingPhone;

  /// Seconds until that code expires, from the register response.
  final int? otpExpireTime;

  /// Whether the user has filled in their profile. Signed-in users who
  /// haven't are kept on the onboarding screens.
  final bool isOnboarded;

  /// This session's API token. Saved to the device only once onboarding is
  /// done, so quitting mid-onboarding means verifying again.
  final String? token;

  const AuthState({
    this.isSignedIn = false,
    this.isOnboarded = false,
    this.pendingPhone,
    this.otpExpireTime,
    this.token,
  });
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final token = ref.read(savedTokenProvider);
    if (token == null) return const AuthState();
    return AuthState(token: token, isSignedIn: true, isOnboarded: true);
  }

  Future<void> register(String phone) async {
    final response = await ref.read(authRepositoryProvider).register(phone);
    state = AuthState(
      pendingPhone: phone,
      otpExpireTime: response.expiresIn,
    );
  }

  /// Signs the user in with the code. Throws [ApiException] if it's wrong.
  Future<void> verifyCode(String phoneNumber, String code) async {
    final response = await ref
        .read(authRepositoryProvider)
        .verifyCode(phoneNumber, code);

    final hasProfile = response.user.name?.trim().isNotEmpty ?? false;

    if (hasProfile) {
      await ref.read(tokenStorageProvider).save(response.token);
    }

    state = AuthState(
      token: response.token,
      isSignedIn: true,
      isOnboarded: hasProfile,
    );
  }

  Future<void> completeOnboarding() async {
    final String token = state.token!;
    await ref.read(tokenStorageProvider).save(token);
    state = AuthState(
      token: token,
      isSignedIn: true,
      isOnboarded: true,
    );
  }

  /// Signs out on the server, then on this device.
  Future<void> signOut() async {
    // First, while the token is still in `state`: the request needs it in
    // its Authorization header to say which session to end.
    try {
      await ref.read(authRepositoryProvider).logout();
    } on ApiException {
      // Offline, or the token had already expired: sign out on the device
      // anyway. The user asked to leave, and a token we've deleted can't
      // be used from this phone again.
    }
    await ref.read(tokenStorageProvider).delete();
    state = const AuthState();
  }
}
