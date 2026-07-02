import 'package:go_router/go_router.dart';
import '../../features/about/pages/about_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/permissions/pages/permissions_page.dart';
import '../../features/protected_apps/pages/protected_apps_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/statistics/pages/statistics_page.dart';
import '../../core/constants/route_constants.dart';
import '../services/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return AppRouter.create(settings.darkMode);
});

class AppRouter {
  static GoRouter create(bool isDark) {
    return GoRouter(
      initialLocation: RoutePaths.dashboard,
      routes: [
        GoRoute(
          path: RoutePaths.dashboard,
          name: RouteNames.dashboard,
          builder: (_, __) => const DashboardPage(),
        ),
        GoRoute(
          path: RoutePaths.permissions,
          name: RouteNames.permissions,
          builder: (_, __) => const PermissionsPage(),
        ),
        GoRoute(
          path: RoutePaths.protectedApps,
          name: RouteNames.protectedApps,
          builder: (_, __) => const ProtectedAppsPage(),
        ),
        GoRoute(
          path: RoutePaths.statistics,
          name: RouteNames.statistics,
          builder: (_, __) => const StatisticsPage(),
        ),
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
