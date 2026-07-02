import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/services/protected_apps_provider.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/utils/app_icons.dart';

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

    final allEnabled = apps.every((a) => a.isEnabled);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Apple-style Header App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  children: [
                    const AppLogo(size: 40, showGlow: false),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gentleman',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        Text(
                          allEnabled ? 'Shield Active' : 'Shield Partially Configured',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: allEnabled ? Colors.green : cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Pulse dot to get attention
                    ProtectionDot(isActive: allEnabled, size: 14),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(LucideIcons.settings, color: cs.onSurfaceVariant),
                      onPressed: () => context.push(RoutePaths.settings),
                    ),
                  ],
                ),
              ),
            ),

            // Apple Group 1: General Status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (allEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            allEnabled ? LucideIcons.shield : LucideIcons.shieldOff,
                            color: allEnabled ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        ),
                        title: const Text(
                          'Accidental Call Interceptor',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          allEnabled ? 'All protected apps are guarded' : 'Tap to enable all shields',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                        trailing: Switch.adaptive(
                          value: allEnabled,
                          activeTrackColor: Colors.green,
                          onChanged: (val) {
                            if (val) {
                              ref.read(protectedAppsProvider.notifier).enableAll();
                            } else {
                              ref.read(protectedAppsProvider.notifier).disableAll();
                            }
                          },
                        ),
                      ),
                      if (stats.lastEvent != null) ...[
                        const Divider(height: 0.5, indent: 60),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.history, color: cs.primary, size: 20),
                          ),
                          title: const Text(
                            'Last Intercepted Event',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${stats.lastEvent!.appName} - ${stats.lastEvent!.interactionLabel}',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),

            // Apple Group 2: Protected Apps
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'PROTECTED APPS'),
            ),
            SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: List.generate(apps.length, (index) {
                    final app = apps[index];
                    final isLast = index == apps.length - 1;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppIcons.colorForPackage(app.packageName).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              AppIcons.iconForPackage(app.packageName),
                              color: AppIcons.colorForPackage(app.packageName),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            app.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: Text(
                            app.isEnabled ? 'Shielding active' : 'Shielding disabled',
                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                          ),
                          trailing: Switch.adaptive(
                            value: app.isEnabled,
                            activeTrackColor: Colors.green,
                            onChanged: (_) {
                              ref.read(protectedAppsProvider.notifier).toggleApp(app.packageName);
                            },
                          ),
                        ),
                        if (!isLast) const Divider(height: 0.5, indent: 64),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // Apple Group 3: Permissions
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'REQUIRED SYSTEM SETTINGS'),
            ),
            SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    _buildPermissionListTile(
                      context: context,
                      icon: LucideIcons.eye,
                      iconColor: Colors.blue,
                      title: 'Accessibility Service',
                      subtitle: 'Intercepts call button taps',
                      status: permissions.accessibilityEnabled,
                      onTap: permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                    ),
                    const Divider(height: 0.5, indent: 64),
                    _buildPermissionListTile(
                      context: context,
                      icon: LucideIcons.layers,
                      iconColor: Colors.purple,
                      title: 'Overlay Permission',
                      subtitle: 'Draws confirmation shield screen',
                      status: permissions.overlayEnabled,
                      onTap: permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
                    ),
                  ],
                ),
              ),
            ),

            // Apple Group 4: Statistics Summary
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'STATISTICS SUMMARY'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildAppleStatCard(
                        context,
                        icon: LucideIcons.shieldCheck,
                        color: Colors.green,
                        value: '${stats.todayCount}',
                        label: 'Saved Today',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildAppleStatCard(
                        context,
                        icon: LucideIcons.clock,
                        color: Colors.blue,
                        value: '${stats.avgHoldDuration.toInt()}ms',
                        label: 'Avg Hold Time',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildPermissionListTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool status,
    required VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = status ? Colors.green : Colors.orange;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status ? 'Active' : 'Configure',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: activeColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            status ? LucideIcons.check : LucideIcons.chevronRight,
            color: activeColor,
            size: 16,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildAppleStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
          ),
        ],
      ),
    );
  }
}
