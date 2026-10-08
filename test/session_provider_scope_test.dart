import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/app/session_provider_scope.dart';
import 'package:diaspora_connect/features/auth/data/auth_provider.dart';
import 'package:diaspora_connect/features/auth/data/auth_repository.dart';
import 'package:diaspora_connect/features/auth/data/token_storage.dart';

/// Stands in for a provider caching the signed-in user's data.
final _userDataProvider = NotifierProvider<_UserData, String>(_UserData.new);

class _UserData extends Notifier<String> {
  @override
  String build() => 'empty';

  void set(String value) => state = value;
}

class _FakeAuthRepository extends Fake implements AuthRepository {
  @override
  Future<void> logout() async {}
}

class _FakeTokenStorage extends Fake implements TokenStorage {
  @override
  Future<void> delete() async {}
}

void main() {
  Future<void> pumpScope(WidgetTester tester, {String? savedToken}) =>
      tester.pumpWidget(
        SessionProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
            tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          ],
          savedToken: savedToken,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Text(ref.watch(_userDataProvider)),
            ),
          ),
        ),
      );

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(Text)));

  testWidgets('signing out forgets the cached user data', (tester) async {
    await pumpScope(tester, savedToken: 'token-a');
    containerOf(tester).read(_userDataProvider.notifier).set("A's issues");
    await tester.pump();
    expect(find.text("A's issues"), findsOneWidget);

    await containerOf(tester).read(authProvider.notifier).signOut();
    await tester.pumpAndSettle();

    expect(find.text("A's issues"), findsNothing);
    expect(find.text('empty'), findsOneWidget);
    // The new session starts signed out, not from the deleted token.
    expect(containerOf(tester).read(authProvider).isSignedIn, isFalse);
  });

  testWidgets('keeps the data while signed in', (tester) async {
    await pumpScope(tester, savedToken: 'token-a');
    final container = containerOf(tester);
    container.read(_userDataProvider.notifier).set("A's issues");
    await tester.pumpAndSettle();

    expect(containerOf(tester), same(container));
    expect(find.text("A's issues"), findsOneWidget);
  });
}
