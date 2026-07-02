import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Shell scaffold that wraps tab-level routes with a bottom NavigationBar.
class ShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({super.key, required this.navigationShell});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(LucideIcons.layoutDashboard),
      selectedIcon: Icon(LucideIcons.layoutDashboard),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.barChart3),
      selectedIcon: Icon(LucideIcons.barChart3),
      label: 'Stats',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.smartphone),
      selectedIcon: Icon(LucideIcons.smartphone),
      label: 'Apps',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.shieldCheck),
      selectedIcon: Icon(LucideIcons.shieldCheck),
      label: 'Permissions',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // Return to root of branch when re-tapping active tab.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: _destinations,
      ),
    );
  }
}
