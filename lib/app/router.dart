import 'package:flutter/material.dart';
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
import '../features/onboarding/onboarding_legal_screen.dart';
import '../features/onboarding/onboarding_personal_screen.dart';
import '../features/onboarding/onboarding_work_screen.dart';
import '../features/personal_details/personal_details_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/report_issue/location_picker_screen.dart';
import '../features/report_issue/models/evidence.dart';
import '../features/report_issue/report_issue_screen.dart';
import '../features/saved_documents/saved_documents_screen.dart';
import '../features/work_details/work_details_screen.dart';
import 'main_shell.dart';

/// Wraps a screen in a MaterialPage, which gives iOS its slide transition and
/// swipe-from-left-edge to go back (Android gets its normal transition).
///
/// Use `pageBuilder: (context, state) => _page(state, ...)` instead of
/// `builder:`: go_router 18 checks for material_ui's MaterialApp, not
/// Flutter's, so with `builder:` it falls back to pages with no transition
/// and no back swipe.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage(key: state.pageKey, child: child);

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

      // New users fill in their profile before using the app, and can't
      // come back to onboarding once it's done.
      final onOnboarding = location.startsWith('/onboarding');
      if (!auth.isOnboarded) {
        return onOnboarding ? null : '/onboarding/personal';
      }
      return onLogin || onOnboarding ? '/home' : null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page(state, const LoginScreen()),
        routes: [
          GoRoute(
            path: 'verify', // → /login/verify
            pageBuilder: (context, state) =>
                _page(state, VerifyCodeScreen(phone: state.extra as String)),
          ),
        ],
      ),
      // Onboarding: one route per step. Each step `push`es the next, so
      // back (swipe or Android back button) returns to the previous step
      // with what was typed still there.
      GoRoute(
        path: '/onboarding/personal',
        pageBuilder: (context, state) =>
            _page(state, const OnboardingPersonalScreen()),
      ),
      GoRoute(
        path: '/onboarding/legal',
        pageBuilder: (context, state) =>
            _page(state, const OnboardingLegalScreen()),
      ),
      GoRoute(
        path: '/onboarding/work',
        pageBuilder: (context, state) =>
            _page(state, const OnboardingWorkScreen()),
      ),
      // Full-screen pages outside the tabs (no bottom nav).
      GoRoute(
        path: '/report-issue',
        pageBuilder: (context, state) =>
            _page(state, const ReportIssueScreen()),
        routes: [
          GoRoute(
            path: 'location', // → /report-issue/location
            pageBuilder: (context, state) => _page(
              state,
              LocationPickerScreen(
                initial: state.extra as PinnedLocation?,
              ),
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    _page(state, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/issues',
                pageBuilder: (context, state) =>
                    _page(state, const IssuesScreen()),
                routes: [
                  GoRoute(
                    path: ':reference', // → /issues/GN-2083-004512
                    // Full screen, no bottom nav (as in the design)
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => _page(
                      state,
                      IssueDetailScreen(
                        reference: state.pathParameters['reference']!,
                      ),
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
                pageBuilder: (context, state) =>
                    _page(state, const ActivityScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    _page(state, const ProfileScreen()),
                routes: [
                  GoRoute(
                    path: 'personal-details', // → /profile/personal-details
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _page(state, const PersonalDetailsScreen()),
                  ),
                  GoRoute(
                    path: 'legal-details', // → /profile/legal-details
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _page(state, const LegalDetailsScreen()),
                  ),
                  GoRoute(
                    path: 'work-details', // → /profile/work-details
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _page(state, const WorkDetailsScreen()),
                  ),
                  GoRoute(
                    path: 'notification-settings',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _page(state, const NotificationSettingsScreen()),
                  ),
                  GoRoute(
                    path: 'saved-documents', // → /profile/saved-documents
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) =>
                        _page(state, const SavedDocumentsScreen()),
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
