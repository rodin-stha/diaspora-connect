import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
        label: l10n.navActivity,
        iconAsset: 'assets/icons/nav_activity.svg',
      ),
      BottomNavItem(
        label: l10n.navProfile,
        iconAsset: 'assets/icons/nav_profile.svg',
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: TBottomNavBar(
        items: navItems,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab again returns to its first page
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
