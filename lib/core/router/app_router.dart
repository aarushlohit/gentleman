import 'package:go_router/go_router.dart';
import '../../features/about/pages/about_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/permissions/pages/permissions_page.dart';
import '../../features/protected_apps/pages/protected_apps_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/statistics/pages/statistics_page.dart';
import '../../features/shell/pages/shell_page.dart';
import '../../core/constants/route_constants.dart';
import '../services/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch darkMode so router rebuilds when it changes (unchanged behaviour).
  ref.watch(appSettingsProvider.select((s) => s.darkMode));
  return AppRouter.create();
});

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: RoutePaths.dashboard,
      routes: [
        // ── Main tab shell ──────────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => ShellPage(navigationShell: shell),
          branches: [
            // Tab 0 — Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.dashboard,
                  name: RouteNames.dashboard,
                  builder: (_, __) => const DashboardPage(),
                ),
              ],
            ),
            // Tab 1 — Statistics
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.statistics,
                  name: RouteNames.statistics,
                  builder: (_, __) => const StatisticsPage(),
                ),
              ],
            ),
            // Tab 2 — Protected Apps
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.protectedApps,
                  name: RouteNames.protectedApps,
                  builder: (_, __) => const ProtectedAppsPage(),
                ),
              ],
            ),
            // Tab 3 — Permissions
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RoutePaths.permissions,
                  name: RouteNames.permissions,
                  builder: (_, __) => const PermissionsPage(),
                ),
              ],
            ),
          ],
        ),

        // ── Pushed routes (no bottom nav) ───────────────────────────────────
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (_, __) => const SettingsPage(),
        ),
        GoRoute(
          path: RoutePaths.about,
          name: RouteNames.about,
          builder: (_, __) => const AboutPage(),
        ),
      ],
    );
  }
}
