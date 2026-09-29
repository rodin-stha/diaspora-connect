import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diaspora_connect/app/locale_provider.dart';
import 'package:diaspora_connect/main.dart';
import 'package:diaspora_connect/widgets/issue_card.dart';
import 'package:diaspora_connect/widgets/selectable_chip.dart';

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

    expect(find.text('Search ticket or subject'), findsOneWidget);
    expect(find.text('All · 4'), findsOneWidget);
  });

  group('Issues screen', () {
    Future<void> openIssuesTab(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows all issues with category in the subtitle', (
      tester,
    ) async {
      await openIssuesTab(tester);

      expect(find.byType(IssueCard), findsNWidgets(4));
      expect(
        find.text('GN-2083-004512 · Wages · Due in 4 days'),
        findsOneWidget,
      );
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('In progress filter includes escalated issues', (
      tester,
    ) async {
      await openIssuesTab(tester);

      // Tap the chip, not the "In progress" status pill on a card
      await tester.tap(find.widgetWithText(SelectableChip, 'In progress'));
      await tester.pumpAndSettle();

      // 1 in progress + 2 escalated; the "New" one is hidden
      expect(find.byType(IssueCard), findsNWidgets(3));
      expect(find.text('Housing dispute, live-in contract'), findsNothing);
    });

    testWidgets('Assigned filter hides issues without a case worker', (
      tester,
    ) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Assigned'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCard), findsNWidgets(3));
      expect(find.text('Housing dispute, live-in contract'), findsNothing);
    });

    testWidgets('Resolved filter shows the empty state', (tester) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Resolved'));
      await tester.pumpAndSettle();

      expect(find.byType(IssueCard), findsNothing);
      expect(find.text('No issues match your search'), findsOneWidget);
    });

    testWidgets('search matches reference number or title', (tester) async {
      await openIssuesTab(tester);

      await tester.enterText(find.byType(TextField), '004530');
      await tester.pumpAndSettle();
      expect(find.byType(IssueCard), findsOneWidget);
      expect(find.text('Housing dispute, live-in contract'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'PASSPORT');
      await tester.pumpAndSettle();
      expect(find.byType(IssueCard), findsOneWidget);
      expect(find.text('Passport held by employer'), findsOneWidget);
    });

    testWidgets('tapping an issue opens Track issue, back returns', (
      tester,
    ) async {
      await openIssuesTab(tester);

      await tester.tap(find.text('Wage shortfall, October pay'));
      await tester.pumpAndSettle();

      expect(find.text('Track issue'), findsOneWidget);
      expect(find.text('GN-2083-004512'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('3 Sep, 10:42 AM'), findsOneWidget);
      expect(find.text('Resolved · pending your feedback'), findsOneWidget);
      // Detail page covers the bottom nav
      expect(find.text('Activity'), findsNothing);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Search ticket or subject'), findsOneWidget);
    });
  });

  group('Activity screen', () {
    Future<void> openActivityTab(WidgetTester tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows account activity newest first', (tester) async {
      await openActivityTab(tester);

      expect(find.text('Submitted a new issue'), findsOneWidget);
      expect(find.text('Changed to +972 5X-XXX-XXXX'), findsOneWidget);
      expect(
        find.text('Passport photo page added to Saved documents'),
        findsOneWidget,
      );
      expect(find.text('6 Sep, 6:40 PM'), findsOneWidget);

      final first = tester.getTopLeft(find.text('Submitted a new issue'));
      final last = tester.getTopLeft(find.text('Profile updated'));
      expect(first.dy, lessThan(last.dy));
    });

    testWidgets('Mark all read disables itself once everything is read', (
      tester,
    ) async {
      await openActivityTab(tester);

      TextButton markAllRead() => tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Mark all read'),
      );
      expect(markAllRead().onPressed, isNotNull);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(markAllRead().onPressed, isNull);
    });
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
