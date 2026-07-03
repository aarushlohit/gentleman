import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(permissionProvider.notifier).refresh());
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final permissions = ref.watch(permissionProvider);
    final readinessCount = [
      permissions.accessibilityEnabled,
      permissions.overlayEnabled,
      permissions.batteryOptimizationDisabled,
    ].where((value) => value).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: const Text('Permissions'),
              actions: [
                IconButton(
                  onPressed: permissions.isLoading ? null : () => ref.read(permissionProvider.notifier).refresh(),
                  icon: const Icon(LucideIcons.refreshCw),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumPill(
                      label: '$readinessCount of 3 system requirements ready',
                      color: readinessCount == 3 ? AppColors.success : AppColors.warning,
                      icon: readinessCount == 3 ? LucideIcons.badgeCheck : LucideIcons.alertTriangle,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Gentleman only feels invisible when Android gives it the right access at the right time.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34, height: 0.98),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    _PermissionTile(
                      title: 'Accessibility service',
                      description: 'Reads supported call button interactions before the remote app can commit to a call.',
                      icon: LucideIcons.eye,
                      accent: AppColors.info,
                      enabled: permissions.accessibilityEnabled,
                      onTap: permissions.accessibilityEnabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                    ),
                    Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 28),
                    _PermissionTile(
                      title: 'Overlay permission',
                      description: 'Lets the confirmation shield appear above WhatsApp and Instagram without breaking flow.',
                      icon: LucideIcons.layers,
                      accent: cs.primary,
                      enabled: permissions.overlayEnabled,
                      onTap: permissions.overlayEnabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
                    ),
                    Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 28),
                    _PermissionTile(
                      title: 'Battery optimization bypass',
                      description: 'Prevents Android from quietly freezing the service when the phone decides to clean house.',
                      icon: LucideIcons.batteryCharging,
                      accent: AppColors.success,
                      enabled: permissions.batteryOptimizationDisabled,
                      onTap: permissions.batteryOptimizationDisabled || permissions.isLoading
                          ? null
                          : () => ref.read(permissionProvider.notifier).openBatterySettings(),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Privacy',
                title: 'Local-first by design',
                subtitle: 'Protection logic, rule configuration, and event history remain on-device.',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(LucideIcons.shield, color: cs.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Gentleman does not need network tracking or cloud storage to prevent accidental calls. The product works best when it stays personal and local.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final bool enabled;
  final VoidCallback? onTap;

  const _PermissionTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    PremiumPill(
                      label: enabled ? 'Ready' : 'Setup',
                      color: enabled ? AppColors.success : AppColors.warning,
                      icon: enabled ? LucideIcons.check : LucideIcons.chevronRight,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
