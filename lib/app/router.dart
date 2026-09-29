import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_screen.dart';
import '../features/auth/data/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/verify_code_screen.dart';
import '../features/home/home_screen.dart';
import '../features/issues/issue_detail_screen.dart';
import '../features/issues/issues_screen.dart';
import '../features/legal_details/legal_details_screen.dart';
import '../features/notification_settings/notification_settings_screen.dart';
import '../features/personal_details/personal_details_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/report_issue/report_issue_screen.dart';
import '../features/saved_documents/saved_documents_screen.dart';
import '../features/work_details/work_details_screen.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // The app-level navigator, above the bottom-nav shell. Pages pushed here
  // cover the bottom nav.
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  // go_router re-runs `redirect` whenever this notifies, so signing in or
  // out moves the user to the right place automatically.
  final authChanges = ValueNotifier(ref.read(authProvider));
  ref.listen(authProvider, (_, next) => authChanges.value = next);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authChanges,
    // Route guard (like Next.js middleware): runs before every navigation.
    // Returns where to go instead, or null to allow it.
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;
      final onLogin = location.startsWith('/login');

      if (!auth.isSignedIn) {
        // Verify only makes sense right after a code was sent.
        if (location == '/login/verify' && auth.pendingPhone == null) {
          return '/login';
        }
        return onLogin ? null : '/login';
      }
      return onLogin ? '/home' : null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'verify', // → /login/verify
            builder: (context, state) => const VerifyCodeScreen(),
          ),
        ],
      ),
      // Full-screen pages outside the tabs (no bottom nav).
      GoRoute(
        path: '/report-issue',
        builder: (context, state) => const ReportIssueScreen(),
      ),
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
  ref.onDispose(() {
    router.dispose();
    authChanges.dispose();
  });
  return router;
});
