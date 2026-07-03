import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/protected_app.dart';
import '../../../core/services/protected_apps_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/premium_widgets.dart';

class ProtectedAppsPage extends ConsumerWidget {
  const ProtectedAppsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final apps = ref.watch(protectedAppsProvider);
    final activeCount = apps.where((app) => app.isEnabled).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text('Protected Apps'),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumPill(
                      label: '$activeCount of ${apps.length} apps actively shielded',
                      color: activeCount == apps.length && apps.isNotEmpty ? AppColors.success : cs.primary,
                      icon: LucideIcons.smartphoneCharging,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Fine-tune which apps get protection, and whether voice or video calls deserve a second layer of intent.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34, height: 0.98),
                    ),
                  ],
                ),
              ),
            ),
            if (apps.isEmpty)
              SliverToBoxAdapter(
                child: PremiumPanel(
                  child: Column(
                    children: [
                      Icon(LucideIcons.smartphone, size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 14),
                      Text(
                        'No supported apps found.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            if (apps.isNotEmpty)
              SliverToBoxAdapter(
                child: PremiumPanel(
                  child: Column(
                    children: [
                      for (var index = 0; index < apps.length; index++) ...[
                        _ProtectedAppRow(
                          app: apps[index],
                          onToggleEnabled: () => ref.read(protectedAppsProvider.notifier).toggleApp(apps[index].packageName),
                          onToggleVoice: () => ref.read(protectedAppsProvider.notifier).toggleVoiceCall(apps[index].packageName),
                          onToggleVideo: () => ref.read(protectedAppsProvider.notifier).toggleVideoCall(apps[index].packageName),
                        ),
                        if (index != apps.length - 1)
                          Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 28),
                      ],
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

class _ProtectedAppRow extends StatelessWidget {
  final ProtectedApp app;
  final VoidCallback onToggleEnabled;
  final VoidCallback onToggleVoice;
  final VoidCallback onToggleVideo;

  const _ProtectedAppRow({
    required this.app,
    required this.onToggleEnabled,
    required this.onToggleVoice,
    required this.onToggleVideo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = AppIcons.colorForPackage(app.packageName);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(AppIcons.iconForPackage(app.packageName), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.displayName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    app.packageName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Switch.adaptive(value: app.isEnabled, onChanged: (_) => onToggleEnabled()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ModeChip(
                label: 'Voice calls',
                icon: LucideIcons.phone,
                active: app.voiceCallProtected,
                activeColor: AppColors.success,
                onTap: app.isEnabled ? onToggleVoice : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeChip(
                label: 'Video calls',
                icon: LucideIcons.video,
                active: app.videoCallProtected,
                activeColor: AppColors.info,
                onTap: app.isEnabled ? onToggleVideo : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.12) : cs.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.24) : cs.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? activeColor : cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active ? activeColor : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              active ? LucideIcons.check : LucideIcons.minus,
              size: 14,
              color: active ? activeColor : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
