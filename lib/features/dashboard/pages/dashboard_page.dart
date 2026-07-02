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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface,
              cs.primary.withValues(alpha: 0.02),
              cs.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Header App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const AppLogo(size: 46, showGlow: true)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gentleman',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              Text(
                                'Dignity Shield active',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Interactive status dot next to settings
                          ProtectionDot(isActive: allEnabled, size: 16),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(LucideIcons.settings, size: 20),
                              onPressed: () => context.push(RoutePaths.settings),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppConstants.appTagline,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Shield Status Card (Glassmorphic Gold Gradient)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                      side: BorderSide(
                        color: cs.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary.withValues(alpha: 0.18),
                            cs.primary.withValues(alpha: 0.04),
                            cs.surface,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                allEnabled ? 'Shield Active' : 'Shield Inactive',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            allEnabled
                                ? '${apps.where((a) => a.isEnabled).length}/${apps.length} apps secured'
                                : 'Accidental touches might occur! Enable shielding.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (stats.lastEvent != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Last blocked: ${stats.lastEvent!.appName} (${stats.lastEvent!.interactionLabel})',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              if (allEnabled) {
                                ref.read(protectedAppsProvider.notifier).disableAll();
                              } else {
                                ref.read(protectedAppsProvider.notifier).enableAll();
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: allEnabled ? cs.error : cs.primary,
                              foregroundColor: allEnabled ? cs.onError : cs.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: Icon(allEnabled ? LucideIcons.shieldOff : LucideIcons.shield, size: 18),
                            label: Text(
                              allEnabled ? 'Disable Shield' : 'Enable Shield',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                ),
              ),

              // Statistics Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Shield Statistics',
                  actionText: 'History',
                  onAction: () => context.go(RoutePaths.statistics),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: LucideIcons.shieldAlert,
                          label: 'Saved Accidental Calls',
                          value: '${stats.todayCount}',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: LucideIcons.hand,
                          label: 'Average Hold Time',
                          value: '${stats.avgHoldDuration.toInt()}ms',
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Protected Apps Section
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
                      subtitle: app.isEnabled ? 'Shield Enabled' : 'Shield Disabled',
                      trailing: Switch(
                        value: app.isEnabled,
                        onChanged: (_) {
                          ref.read(protectedAppsProvider.notifier).toggleApp(app.packageName);
                        },
                      ),
                      animDelayMs: (index + 1) * 80,
                    );
                  },
                  childCount: apps.length,
                ),
              ),

              // Permission status Section
              SliverToBoxAdapter(
                child: SectionHeader(title: 'Required Permissions'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      _PermissionCard(
                        icon: LucideIcons.eye,
                        label: 'Accessibility Service',
                        subtitle: 'Monitors call clicks inside target apps.',
                        status: permissions.accessibilityEnabled,
                        onTap: permissions.isLoading
                            ? null
                            : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                      ),
                      const SizedBox(height: 8),
                      _PermissionCard(
                        icon: LucideIcons.layers,
                        label: 'System Overlay Window',
                        subtitle: 'Draws the verification prompt screen.',
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool status;
  final VoidCallback? onTap;

  const _PermissionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = status ? Colors.green : cs.error;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: activeColor.withValues(alpha: 0.15), width: 1.2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: activeColor,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            status ? 'Permission Active' : subtitle,
            style: TextStyle(
              fontSize: 12,
              color: status ? Colors.green : cs.onSurfaceVariant,
            ),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status ? 'Active' : 'Setup',
            style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
