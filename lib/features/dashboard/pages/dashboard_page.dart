import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/services/protected_apps_provider.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/status_card.dart';
import '../../../core/utils/app_icons.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(permissionProvider.notifier).refresh();
      ref.read(statisticsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final permissions = ref.watch(permissionProvider);
    final stats = ref.watch(statisticsProvider);
    final apps = ref.watch(protectedAppsProvider);

    final allEnabled = apps.every((a) => a.isEnabled);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: 12),
                        Text(
                          'Gentleman',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(LucideIcons.settings),
                          onPressed: () => context.push(RoutePaths.settings),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppConstants.appTagline,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withValues(alpha: 0.15),
                          cs.primary.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        ProtectionDot(isActive: allEnabled, size: 24),
                        const SizedBox(height: 12),
                        Text(
                          allEnabled ? 'Protection Active' : 'Protection Inactive',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          allEnabled
                              ? '${apps.where((a) => a.isEnabled).length}/${apps.length} apps protected'
                              : 'Enable apps in Protected Apps',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        if (stats.lastEvent != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Last: ${stats.lastEvent!.appName} - ${stats.lastEvent!.interactionLabel}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {
                            if (allEnabled) {
                              ref.read(protectedAppsProvider.notifier).disableAll();
                            } else {
                              ref.read(protectedAppsProvider.notifier).enableAll();
                            }
                          },
                          icon: Icon(allEnabled ? LucideIcons.shieldOff : LucideIcons.shield),
                          label: Text(allEnabled ? 'Disable All' : 'Enable All'),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Today\'s Stats',
                actionText: 'Details',
                onAction: () => context.push(RoutePaths.statistics),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.shieldOff,
                        label: 'Prevented',
                        value: '${stats.todayCount}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatTile(
                        icon: LucideIcons.clock,
                        label: 'Avg Hold',
                        value: '${stats.avgHoldDuration.toInt()}ms',
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Protected Apps'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = apps[index];
                  return StatusCard(
                    icon: AppIcons.iconForPackage(app.packageName),
                    iconColor: AppIcons.colorForPackage(app.packageName),
                    title: app.displayName,
                    subtitle: app.isEnabled ? 'Active' : 'Disabled',
                    trailing: Switch(
                      value: app.isEnabled,
                      onChanged: (_) {
                        ref.read(protectedAppsProvider.notifier).toggleApp(app.packageName);
                      },
                    ),
                    animDelayMs: (index + 1) * 100,
                  );
                },
                childCount: apps.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Permissions'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    _PermissionTile(
                      icon: LucideIcons.eye,
                      label: 'Accessibility',
                      status: permissions.accessibilityEnabled,
                      onTap: permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                    ),
                    const SizedBox(height: 6),
                    _PermissionTile(
                      icon: LucideIcons.layers,
                      label: 'Overlay',
                      status: permissions.overlayEnabled,
                      onTap: permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                )),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool status;
  final VoidCallback? onTap;

  const _PermissionTile({
    required this.icon,
    required this.label,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (status ? Colors.green : cs.error).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: status ? Colors.green : cs.error,
            size: 18,
          ),
        ),
        title: Text(label),
        subtitle: Text(status ? 'Granted' : 'Not granted'),
        trailing: Icon(
          status ? LucideIcons.checkCircle : LucideIcons.xCircle,
          color: status ? Colors.green : cs.error,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
