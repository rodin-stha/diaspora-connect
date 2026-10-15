import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/app/api/paged.dart';
import 'package:diaspora_connect/features/announcements/data/announcements_repository.dart';
import 'package:diaspora_connect/features/announcements/models/announcement.dart';
import 'package:diaspora_connect/features/announcements/notice_detail_screen.dart';
import 'package:diaspora_connect/features/announcements/notices_screen.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';
import 'package:diaspora_connect/widgets/skeleton.dart';

const _longDescription =
    'Every office will be closed this Sunday for the national holiday. '
    'Offices open again on Monday at the usual time. For urgent help, '
    'call the helpline from the Home screen.';

Announcement _notice(
  int id, {
  String? title,
  String? description,
  bool hasImage = true,
}) => Announcement(
  id: id,
  title: title ?? 'Notice $id',
  description: description,
  image: hasImage
      ? AnnouncementImage(
          url: 'https://example.com/$id.jpg',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        )
      : null,
);

/// Serves [all] a page at a time, like the API. Pages after the first wait
/// for [nextPage], so a test can look at the loading state.
class _FakeRepository implements AnnouncementsRepository {
  final List<Announcement> all;
  final requestedPages = <int>[];
  Completer<void>? nextPage;

  _FakeRepository(this.all);

  @override
  Future<Paged<Announcement>> fetchAnnouncementsPage({
    required int page,
    required int perPage,
  }) async {
    requestedPages.add(page);
    if (page > 1) await nextPage?.future;
    final start = (page - 1) * perPage;
    return Paged(
      items: all.skip(start).take(perPage).toList(),
      hasMore: start + perPage < all.length,
    );
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpApp(
    WidgetTester tester, {
    required String initialLocation,
    required _FakeRepository repository,
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
          announcementsRepositoryProvider.overrideWithValue(repository),
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
      repository: _FakeRepository([
        _notice(6, title: 'Holiday notice', description: _longDescription),
      ]),
    );

    final description = tester.widget<Text>(find.text(_longDescription));
    expect(description.maxLines, 2);
    expect(description.overflow, TextOverflow.ellipsis);
  });

  testWidgets('scrolling down loads the next page, with a skeleton meanwhile', (
    tester,
  ) async {
    final repository = _FakeRepository([
      for (var id = 1; id <= 8; id++) _notice(id),
    ])..nextPage = Completer();
    await pumpApp(tester, initialLocation: '/notices', repository: repository);

    // First page: 5 per page.
    expect(repository.requestedPages, [1]);
    expect(find.text('Notice 5'), findsOneWidget);
    expect(find.text('Notice 6', skipOffstage: false), findsNothing);

    await tester.drag(find.byType(Scrollable), const Offset(0, -3000));
    await tester.pump();
    expect(repository.requestedPages, [1, 2]);
    expect(find.byType(Skeleton, skipOffstage: false), findsOneWidget);

    repository.nextPage!.complete();
    await tester.pump();
    await tester.pump();
    expect(find.text('Notice 8', skipOffstage: false), findsOneWidget);
    // That was the last page: no third request, however far it scrolls.
    await tester.drag(find.byType(Scrollable), const Offset(0, -3000));
    await tester.pump();
    expect(repository.requestedPages, [1, 2]);
  });

  testWidgets('text-only notices show, and a short list keeps loading', (
    tester,
  ) async {
    // Like the API's page 4: notices without images. Small cards don't
    // fill the screen, so there's no scroll to trigger the next page.
    final repository = _FakeRepository([
      for (var id = 1; id <= 12; id++) _notice(id, hasImage: false),
    ]);
    await pumpApp(tester, initialLocation: '/notices', repository: repository);
    for (var i = 0; i < 6; i++) {
      await tester.pump();
    }

    expect(repository.requestedPages, [1, 2, 3]);
    expect(find.text('Notice 12', skipOffstage: false), findsOneWidget);
  });

  testWidgets('tapping a notice opens it with its whole description', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initialLocation: '/notices',
      repository: _FakeRepository([
        _notice(6, title: 'Holiday notice', description: _longDescription),
      ]),
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
      repository: _FakeRepository([_notice(6)]),
    );
    expect(find.text('This notice is no longer available.'), findsOneWidget);
  });
}
