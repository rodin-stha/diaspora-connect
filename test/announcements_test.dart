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
  imageUrl: 'https://example.com/$id.jpg',
  imageExpiresAt: DateTime.now().add(const Duration(hours: 1)),
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
      expect(announcement.imageUrl, contains('signature=x'));
      expect(
        announcement.imageExpiresAt,
        DateTime.utc(2026, 10, 8, 6, 36, 15),
      );
    });
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
      expect(find.text('Embassy closed Friday'), findsOneWidget);

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
