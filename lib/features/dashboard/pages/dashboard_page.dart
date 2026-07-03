import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/protected_apps_provider.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/premium_widgets.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      ref.read(permissionProvider.notifier).refresh();
      ref.read(statisticsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionProvider.notifier).refresh();
      ref.read(statisticsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final permissions = ref.watch(permissionProvider);
    final stats = ref.watch(statisticsProvider);
    final apps = ref.watch(protectedAppsProvider);
    final enabledApps = apps.where((app) => app.isEnabled).length;
    final allEnabled = apps.isNotEmpty && apps.every((app) => app.isEnabled);
    final permissionReady = permissions.accessibilityEnabled && permissions.overlayEnabled;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    const AppLogo(size: 52, showGlow: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gentleman', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Protection that feels deliberate, not loud.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProtectionDot(isActive: allEnabled && permissionReady, size: 14),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: () => context.push(RoutePaths.settings),
                      icon: const Icon(LucideIcons.settings2, size: 18),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        PremiumPill(
                          label: allEnabled ? 'Shield fully armed' : 'Shield needs attention',
                          color: allEnabled ? AppColors.success : AppColors.warning,
                          icon: allEnabled ? LucideIcons.shieldCheck : LucideIcons.alertTriangle,
                        ),
                        PremiumPill(
                          label: permissionReady ? 'Permissions ready' : 'Permissions incomplete',
                          color: permissionReady ? AppColors.info : AppColors.warning,
                          icon: permissionReady ? LucideIcons.badgeCheck : LucideIcons.lock,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'A premium control surface for protecting accidental calls before they can start.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 38,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The first tap is sacrificed instantly. The second tap only exists after explicit intent.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (allEnabled) {
                                ref.read(protectedAppsProvider.notifier).disableAll();
                              } else {
                                ref.read(protectedAppsProvider.notifier).enableAll();
                              }
                            },
                            child: Text(allEnabled ? 'Pause Shield' : 'Arm Everything'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push(RoutePaths.permissions),
                            child: const Text('Review Permissions'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Blocked today',
                        value: '${stats.todayCount}',
                        icon: LucideIcons.shieldAlert,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Apps armed',
                        value: '$enabledApps/${apps.length}',
                        icon: LucideIcons.smartphoneCharging,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Hold average',
                        value: '${stats.avgHoldDuration.toInt()}ms',
                        icon: LucideIcons.timerReset,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Overview',
                title: 'Protection surfaces',
                subtitle: 'Core apps and safety checks in one place.',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    for (var index = 0; index < apps.length; index++) ...[
                      _AppTile(
                        appName: apps[index].displayName,
                        subtitle: apps[index].isEnabled ? 'Monitoring enabled' : 'Monitoring paused',
                        packageName: apps[index].packageName,
                        enabled: apps[index].isEnabled,
                        onChanged: () => ref.read(protectedAppsProvider.notifier).toggleApp(apps[index].packageName),
                      ),
                      if (index != apps.length - 1)
                        Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 24),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'System',
                title: 'Permission posture',
                subtitle: 'Accessibility, overlay, and endurance settings determine whether shielding can fire on time.',
                trailing: IconButton(
                  onPressed: permissions.isLoading ? null : () => ref.read(permissionProvider.notifier).refresh(),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    _PermissionRow(
                      title: 'Accessibility service',
                      subtitle: 'Reads call click events from supported apps.',
                      icon: LucideIcons.eye,
                      enabled: permissions.accessibilityEnabled,
                      accent: AppColors.info,
                      onTap: permissions.accessibilityEnabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                    ),
                    Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 24),
                    _PermissionRow(
                      title: 'Overlay permission',
                      subtitle: 'Presents the hold-to-confirm shield above third-party apps.',
                      icon: LucideIcons.layers,
                      enabled: permissions.overlayEnabled,
                      accent: cs.primary,
                      onTap: permissions.overlayEnabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
                    ),
                    Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 24),
                    _PermissionRow(
                      title: 'Battery optimization',
                      subtitle: 'Keeps the interception engine alive during long sessions.',
                      icon: LucideIcons.batteryCharging,
                      enabled: permissions.batteryOptimizationDisabled,
                      accent: AppColors.success,
                      onTap: permissions.batteryOptimizationDisabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openBatterySettings(),
                    ),
                  ],
                ),
              ),
            ),
            if (stats.lastEvent != null) ...[
              const SliverToBoxAdapter(
                child: PremiumSectionTitle(
                  eyebrow: 'Latest',
                  title: 'Most recent intercept',
                ),
              ),
              SliverToBoxAdapter(
                child: PremiumPanel(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppIcons.colorForPackage(stats.lastEvent!.packageName).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          AppIcons.iconForPackage(stats.lastEvent!.packageName),
                          color: AppIcons.colorForPackage(stats.lastEvent!.packageName),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.lastEvent!.appName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stats.lastEvent!.interactionLabel} intercepted successfully',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PremiumPill(
                        label: 'Recorded',
                        color: AppColors.success,
                        icon: LucideIcons.check,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final String appName;
  final String subtitle;
  final String packageName;
  final bool enabled;
  final VoidCallback onChanged;

  const _AppTile({
    required this.appName,
    required this.subtitle,
    required this.packageName,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppIcons.colorForPackage(packageName);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(AppIcons.iconForPackage(packageName), color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Switch.adaptive(value: enabled, onChanged: (_) => onChanged()),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final Color accent;
  final VoidCallback? onTap;

  const _PermissionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PremiumPill(
              label: enabled ? 'Ready' : 'Action needed',
              color: enabled ? AppColors.success : AppColors.warning,
              icon: enabled ? LucideIcons.check : LucideIcons.chevronRight,
            ),
          ],
        ),
      ),
    );
  }
}
