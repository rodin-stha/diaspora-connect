import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diaspora_connect/app/locale_provider.dart';
import 'package:diaspora_connect/main.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  Map<String, Object> savedPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(savedPrefs);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  // Tests have no network access, so don't try to download fonts.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Home screen shows greeting, report card and issues', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Namaste, Sita'), findsOneWidget);
    expect(find.text('Report an issue'), findsOneWidget);
    expect(find.text('Wage shortfall, October pay'), findsOneWidget);
    expect(find.text('GN-2083-004512 · Due in 4 days'), findsOneWidget);
    expect(find.text('GN-2083-004498 · Overdue'), findsOneWidget);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Escalated'), findsOneWidget);
  });

  testWidgets('View all opens the Issues tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(Center, 'Issues'), findsOneWidget);
  });

  testWidgets('Language toggle switches to Nepali and saves the choice', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('ने'));
    await tester.pumpAndSettle();

    expect(find.text('नमस्ते, Sita'), findsOneWidget);
    expect(find.text('समस्या रिपोर्ट गर्नुहोस्'), findsOneWidget);
    expect(find.text('गृहपृष्ठ'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_locale'), 'ne');

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Namaste, Sita'), findsOneWidget);
  });

  testWidgets('Saved language is used on launch', (tester) async {
    await pumpApp(tester, savedPrefs: {'app_locale': 'ne'});

    expect(find.text('नमस्ते, Sita'), findsOneWidget);
  });
}
