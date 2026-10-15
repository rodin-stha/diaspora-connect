import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/app/main_shell.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';

/// The five tabs, as plain pages showing their path.
const _paths = ['/home', '/issues', '/notices', '/activity', '/profile'];

Future<GoRouter> _pumpShell(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          for (final path in _paths)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: path,
                  builder: (context, state) =>
                      Scaffold(body: Center(child: Text('page $path'))),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    MaterialApp.router(
      theme: TAppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String _currentPath(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.path;

/// What Android's back button or back swipe sends.
Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('back goes to the previously visited tabs', (tester) async {
    final router = await _pumpShell(tester);

    await tester.tap(find.text('Notice'));
    await tester.pumpAndSettle();
    // Not from the bottom bar, like Home's Notice tile.
    router.go('/activity');
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/activity');

    await _systemBack(tester);
    expect(_currentPath(router), '/notices');
    await _systemBack(tester);
    expect(_currentPath(router), '/home');
  });

  testWidgets('each tab is in the history once', (tester) async {
    final router = await _pumpShell(tester);

    // Home → Notice → Home → Activity: back goes Home, then Notice.
    for (final tab in ['Notice', 'Home', 'Activity']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }

    await _systemBack(tester);
    expect(_currentPath(router), '/home');
    await _systemBack(tester);
    expect(_currentPath(router), '/notices');
  });

  testWidgets('on iOS, a swipe from the left edge goes back', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      final router = await _pumpShell(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      await tester.dragFrom(const Offset(5, 300), const Offset(150, 0));
      await tester.pumpAndSettle();
      expect(_currentPath(router), '/home');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
