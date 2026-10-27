import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diaspora_connect/app/api/api_exception.dart';
import 'package:diaspora_connect/app/api/dio_provider.dart';
import 'package:diaspora_connect/app/image_cache_provider.dart';
import 'package:diaspora_connect/app/locale_provider.dart';
import 'package:diaspora_connect/features/auth/data/auth_provider.dart';
import 'package:diaspora_connect/features/auth/data/token_storage.dart';

import 'fakes/fake_image_cache.dart';

/// Answers every request with [statusCode], without touching the network.
class _FakeAdapter implements HttpClientAdapter {
  final int statusCode;

  _FakeAdapter(this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"success": false, "message": "Unauthenticated."}',
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _FakeTokenStorage extends Fake implements TokenStorage {
  int deletes = 0;

  @override
  Future<void> delete() async => deletes++;
}

void main() {
  late _FakeTokenStorage tokenStorage;

  Future<ProviderContainer> signedIn({String? token = 'expired-token'}) async {
    SharedPreferences.setMockInitialValues({});
    tokenStorage = _FakeTokenStorage();
    final container = ProviderContainer(
      overrides: [
        imageCacheProvider.overrideWithValue(FakeImageCache()),
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        savedTokenProvider.overrideWithValue(token),
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
    );
    addTearDown(container.dispose);
    container.read(dioProvider).httpClientAdapter = _FakeAdapter(401);
    return container;
  }

  Future<void> get(ProviderContainer container, String path) async {
    final dio = container.read(dioProvider);
    await expectLater(
      apiCall(() => dio.get<void>(path)),
      throwsA(
        isA<ApiException>().having(
          (e) => e.type,
          'type',
          ApiErrorType.unauthorized,
        ),
      ),
    );
  }

  test('a 401 on a signed-in request signs out on this device', () async {
    final container = await signedIn();

    await get(container, '/issues');

    expect(container.read(authProvider).isSignedIn, isFalse);
    expect(tokenStorage.deletes, 1);
  });

  test('several 401s at once sign out only once', () async {
    final container = await signedIn();

    await Future.wait([
      get(container, '/issues'),
      get(container, '/activity'),
      get(container, '/profile'),
    ]);

    expect(tokenStorage.deletes, 1);
  });

  test('a 401 on the logout request is left to signOut', () async {
    final container = await signedIn();

    await get(container, '/logout');

    expect(container.read(authProvider).isSignedIn, isTrue);
    expect(tokenStorage.deletes, 0);
  });

  test('a 401 without a token (e.g. on Login) is not a sign-out', () async {
    final container = await signedIn(token: null);

    await get(container, '/register/verify-otp');

    expect(tokenStorage.deletes, 0);
  });
}
