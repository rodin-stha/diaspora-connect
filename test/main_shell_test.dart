import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diaspora_connect/app/main_shell.dart';
import 'package:diaspora_connect/app/tab_switch_container.dart';
import 'package:diaspora_connect/l10n/app_localizations.dart';
import 'package:diaspora_connect/theme/app_theme.dart';

/// The five tabs, as plain pages showing their path.
const _paths = ['/home', '/issues', '/notices', '/activity', '/profile'];

/// A page with a counter, to check a tab keeps its state.
class _CounterPage extends StatefulWidget {
  final String path;

  const _CounterPage(this.path);

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => setState(() => _count++),
        child: Text('page ${widget.path} $_count'),
      ),
    ),
  );
}

Future<GoRouter> _pumpShell(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            TabSwitchContainer(
              currentIndex: shell.currentIndex,
              children: children,
            ),
        branches: [
          for (final path in _paths)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: path,
                  builder: (context, state) => _CounterPage(path),
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

  testWidgets('going back slides the tab away over the previous one', (
    tester,
  ) async {
    final router = await _pumpShell(tester);
    await tester.tap(find.text('Activity'));
    // Tapping a tab: instant, no animation.
    await tester.pump();
    expect(find.textContaining('page /home'), findsNothing);
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    // Mid-animation: both on screen.
    expect(find.textContaining('page /activity'), findsOneWidget);
    expect(find.textContaining('page /home'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(_currentPath(router), '/home');
    expect(find.textContaining('page /activity'), findsNothing);
  });

  testWidgets('a tab keeps its state through the animation', (tester) async {
    await _pumpShell(tester);
    await tester.tap(find.text('page /home 0'));
    await tester.pump();
    await tester.tap(find.text('Notice'));
    await tester.pumpAndSettle();

    await _systemBack(tester);
    expect(find.text('page /home 1'), findsOneWidget);
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
