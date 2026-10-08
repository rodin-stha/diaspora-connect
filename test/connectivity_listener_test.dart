import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diaspora_connect/features/connectivity/connectivity_listener.dart';
import 'package:diaspora_connect/features/connectivity/data/connectivity_provider.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';

const _offline = 'No internet connection';
const _backOnline = 'Back online';
const _navKey = Key('nav');

void main() {
  late StreamController<bool> online;

  setUp(() => online = StreamController<bool>());
  tearDown(() => online.close());

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [isOnlineProvider.overrideWith((ref) => online.stream)],
      child: MaterialApp(
        theme: TAppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ConnectivityListener(child: child!),
        home: const Scaffold(
          body: Text('HOME'),
          bottomNavigationBar: SizedBox(key: _navKey, height: 80),
        ),
      ),
    ),
  );

  testWidgets('nothing while online or still checking', (tester) async {
    await pumpApp(tester);
    expect(find.text(_offline), findsNothing);

    online.add(true);
    await tester.pumpAndSettle();
    expect(find.text(_offline), findsNothing);
    expect(find.text(_backOnline), findsNothing);
  });

  testWidgets('shows above the bottom nav and can\'t be dismissed', (
    tester,
  ) async {
    await pumpApp(tester);
    online.add(false);
    await tester.pumpAndSettle();
    expect(find.text(_offline), findsOneWidget);

    final pill = find.byType(SnackBar);
    final navTop = tester.getTopLeft(find.byKey(_navKey)).dy;
    expect(tester.getBottomLeft(pill).dy, lessThanOrEqualTo(navTop));

    // Swiping, tapping or waiting doesn't remove it.
    await tester.drag(pill, const Offset(0, 300));
    await tester.tap(find.text(_offline));
    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();
    expect(find.text(_offline), findsOneWidget);
  });

  testWidgets('says "Back online" briefly when the connection returns', (
    tester,
  ) async {
    await pumpApp(tester);
    online.add(false);
    await tester.pumpAndSettle();

    online.add(true);
    await tester.pumpAndSettle();
    expect(find.text(_offline), findsNothing);
    expect(find.text(_backOnline), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(_backOnline), findsNothing);
  });
}
