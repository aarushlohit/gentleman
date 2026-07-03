import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.82),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.85)),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                backgroundColor: Colors.transparent,
                indicatorColor: cs.primary.withValues(alpha: 0.12),
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                destinations: _destinations,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
