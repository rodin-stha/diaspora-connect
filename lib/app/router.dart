import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_screen.dart';
import '../features/home/home_screen.dart';
import '../features/issues/issue_detail_screen.dart';
import '../features/issues/issues_screen.dart';
import '../features/legal_details/legal_details_screen.dart';
import '../features/notification_settings/notification_settings_screen.dart';
import '../features/personal_details/personal_details_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/saved_documents/saved_documents_screen.dart';
import '../features/work_details/work_details_screen.dart';
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
                builder: (context, state) => const ActivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'personal-details', // → /profile/personal-details
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PersonalDetailsScreen(),
                  ),
                  GoRoute(
                    path: 'legal-details', // → /profile/legal-details
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const LegalDetailsScreen(),
                  ),
                  GoRoute(
                    path: 'work-details', // → /profile/work-details
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const WorkDetailsScreen(),
                  ),
                  GoRoute(
                    path: 'notification-settings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        const NotificationSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'saved-documents', // → /profile/saved-documents
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SavedDocumentsScreen(),
                  ),
                ],
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
