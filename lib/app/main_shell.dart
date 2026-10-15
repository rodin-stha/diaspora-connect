import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';

/// Width of the strip along the left edge where a swipe goes back (iOS).
const _edgeWidth = 20.0;

/// How far or fast a swipe must go to count, so a slight drag doesn't.
const _minSwipeDistance = 60.0;
const _minSwipeVelocity = 300.0;

class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Tabs visited before the current one, most recent last. Each tab once:
  /// going back from Activity after Home → Notice → Home → Activity lands
  /// on Home, then Notice.
  final _history = <int>[];

  /// True while switching tabs because of "back", so that switch isn't
  /// added to the history.
  bool _goingBack = false;

  double _swipeDistance = 0;

  int get _currentIndex => widget.navigationShell.currentIndex;

  /// Records every tab change, whatever caused it: the bottom bar, or a
  /// link elsewhere (e.g. Home's Notice tile calls `context.go`).
  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.navigationShell.currentIndex;
    if (previous == _currentIndex) return;

    if (_goingBack) {
      _goingBack = false;
    } else {
      _history
        ..remove(previous)
        ..add(previous);
    }
    _history.remove(_currentIndex);
  }

  void _goBack() {
    if (_history.isEmpty) return;
    _goingBack = true;
    widget.navigationShell.goBranch(_history.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navigationShell = widget.navigationShell;

    // Order must match the branches in router.dart
    final navItems = [
      BottomNavItem(
        label: l10n.navHome,
        iconAsset: 'assets/icons/nav_home.svg',
      ),
      BottomNavItem(
        label: l10n.navIssues,
        iconAsset: 'assets/icons/nav_issues.svg',
      ),
      BottomNavItem(
        label: l10n.navNotice,
        iconAsset: 'assets/icons/nav_notice.svg',
      ),
      BottomNavItem(
        label: l10n.navActivity,
        iconAsset: 'assets/icons/nav_activity.svg',
      ),
      BottomNavItem(
        label: l10n.navProfile,
        iconAsset: 'assets/icons/nav_profile.svg',
      ),
    ];

    // Android's back button and back swipe (from either edge, with gesture
    // navigation) both arrive here. With tabs to go back to, go to the
    // previous one instead of closing the app.
    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_goBack);
      },
      child: Scaffold(
        body: Stack(
          children: [
            navigationShell,
            // iOS has no system back gesture for tabs, so watch the left edge
            // ourselves. Not on Android: the system already turns that swipe
            // into "back" (handled above).
            if (defaultTargetPlatform == TargetPlatform.iOS &&
                _history.isNotEmpty)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _edgeWidth,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) => _swipeDistance = 0,
                  onHorizontalDragUpdate: (details) =>
                      _swipeDistance += details.delta.dx,
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (_swipeDistance > _minSwipeDistance ||
                        velocity > _minSwipeVelocity) {
                      setState(_goBack);
                    }
                  },
                ),
              ),
          ],
        ),
        bottomNavigationBar: TBottomNavBar(
          items: navItems,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            // Tapping the active tab again returns to its first page
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
