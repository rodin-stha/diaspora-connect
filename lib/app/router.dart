import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/issues/issue_detail_screen.dart';
import '../features/issues/issues_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/placeholder_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // The app-level navigator, above the bottom-nav shell. Pages pushed here
  // cover the bottom nav.
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/issues',
                builder: (context, state) => const IssuesScreen(),
                routes: [
                  GoRoute(
                    path: ':reference', // → /issues/GN-2083-004512
                    // Full screen, no bottom nav (as in the design)
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => IssueDetailScreen(
                      reference: state.pathParameters['reference']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => PlaceholderScreen(
                  title: AppLocalizations.of(context).navActivity,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => PlaceholderScreen(
                  title: AppLocalizations.of(context).navProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
