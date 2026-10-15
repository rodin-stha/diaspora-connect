import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/features/announcements/data/announcements_provider.dart';
import 'package:diaspora_connect/features/announcements/models/announcement.dart';
import 'package:diaspora_connect/features/announcements/notice_detail_screen.dart';
import 'package:diaspora_connect/features/announcements/notices_screen.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';

const _longDescription =
    'Every office will be closed this Sunday for the national holiday. '
    'Offices open again on Monday at the usual time. For urgent help, '
    'call the helpline from the Home screen.';

final _notice = Announcement(
  id: 6,
  title: 'Holiday notice',
  description: _longDescription,
  imageUrl: 'https://example.com/6.jpg',
  imageExpiresAt: DateTime.now().add(const Duration(hours: 1)),
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpApp(
    WidgetTester tester, {
    required String initialLocation,
    required List<Announcement> announcements,
  }) async {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/notices',
          builder: (context, state) => const NoticesScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => NoticeDetailScreen(
                id: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allAnnouncementsProvider.overrideWith((ref) async => announcements),
        ],
        child: MaterialApp.router(
          theme: TAppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    // Network images never load in tests, so pumpAndSettle would wait on
    // the loading skeleton's animation forever.
    await tester.pump();
    await tester.pump();
  }

  testWidgets('the list cuts the description to two lines', (tester) async {
    await pumpApp(
      tester,
      initialLocation: '/notices',
      announcements: [_notice],
    );

    final description = tester.widget<Text>(find.text(_longDescription));
    expect(description.maxLines, 2);
    expect(description.overflow, TextOverflow.ellipsis);
  });

  testWidgets('tapping a notice opens it with its whole description', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initialLocation: '/notices',
      announcements: [_notice],
    );

    await tester.tap(find.text('Holiday notice'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(NoticeDetailScreen), findsOneWidget);
    final description = tester.widget<Text>(
      find.descendant(
        of: find.byType(NoticeDetailScreen),
        matching: find.text(_longDescription),
      ),
    );
    expect(description.maxLines, isNull);
  });

  testWidgets('a notice that is gone says so', (tester) async {
    await pumpApp(
      tester,
      initialLocation: '/notices/99',
      announcements: [_notice],
    );
    expect(find.text('This notice is no longer available.'), findsOneWidget);
  });
}
