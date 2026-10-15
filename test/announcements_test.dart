import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/features/announcements/data/announcements_provider.dart';
import 'package:diaspora_connect/features/announcements/models/announcement.dart';
import 'package:diaspora_connect/features/announcements/widgets/announcement_viewer.dart';
import 'package:diaspora_connect/features/announcements/widgets/announcements_section.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:diaspora_connect/widgets/page_dots.dart';

Announcement _announcement(int id, {String? title}) => Announcement(
  id: id,
  title: title,
  image: AnnouncementImage(
    url: 'https://example.com/$id.jpg',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  ),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('Announcement.fromJson', () {
    test('reads the API sample', () {
      final announcement = Announcement.fromJson({
        'id': 2,
        'title': null,
        'description': '  ',
        'image': {
          'id': 44,
          'url': 'https://diaspora.kumo-labs.com/storage/44/a.jpg?signature=x',
          'expires_at': '2026-10-08T06:36:15+00:00',
        },
      });

      expect(announcement.id, 2);
      expect(announcement.title, isNull);
      // Blank counts as none, so the viewer doesn't show an empty caption.
      expect(announcement.description, isNull);
      expect(announcement.image!.url, contains('signature=x'));
      expect(
        announcement.image!.expiresAt,
        DateTime.utc(2026, 10, 8, 6, 36, 15),
      );
    });
  });

  test('reads a text-only announcement (no image)', () {
    final announcement = Announcement.fromJson({
      'id': 11,
      'title': 'Beware of fake job offers',
      'description': 'Do not pay anyone for a job offer or visa change.',
      'image': null,
      'created_at': '2026-09-25T10:00:00+00:00',
      'updated_at': '2026-09-25T10:00:00+00:00',
    });

    expect(announcement.title, 'Beware of fake job offers');
    expect(announcement.image, isNull);
  });

  group('AnnouncementsSection', () {
    Future<void> pumpSection(
      WidgetTester tester,
      Future<List<Announcement>> Function() fetch,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [announcementsProvider.overrideWith((ref) => fetch())],
          child: MaterialApp(
            theme: TAppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SingleChildScrollView(child: AnnouncementsSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hides itself when there are none', (tester) async {
      await pumpSection(tester, () async => []);
      expect(find.text('Announcements'), findsNothing);
    });

    testWidgets('shows a carousel with one dot per announcement', (
      tester,
    ) async {
      await pumpSection(
        tester,
        () async => [_announcement(1), _announcement(2)],
      );

      expect(find.text('Announcements'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(
        tester.widget<PageDots>(find.byType(PageDots)).count,
        2,
      );
    });

    testWidgets('no dots for a single announcement', (tester) async {
      await pumpSection(tester, () async => [_announcement(1)]);
      expect(find.byType(PageDots), findsNothing);
    });

    testWidgets('shows the title on the banner', (tester) async {
      await pumpSection(
        tester,
        () async => [_announcement(1, title: 'Embassy closed Friday')],
      );
      expect(find.text('Embassy closed Friday'), findsOneWidget);
    });

    testWidgets('tapping one opens it full screen with its title', (
      tester,
    ) async {
      await pumpSection(
        tester,
        () async => [_announcement(1, title: 'Embassy closed Friday')],
      );

      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementViewer), findsOneWidget);
      // The banner behind the viewer shows it too, so look in the viewer.
      expect(
        find.descendant(
          of: find.byType(AnnouncementViewer),
          matching: find.text('Embassy closed Friday'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(AnnouncementViewer), findsNothing);
    });

    testWidgets('a failed fetch offers a retry', (tester) async {
      await pumpSection(tester, () async => throw Exception('offline'));
      expect(find.text("Couldn't load announcements."), findsOneWidget);
    });
  });
}
