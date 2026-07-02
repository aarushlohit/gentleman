import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/permission_service.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(permissionProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final permissions = ref.watch(permissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _PermissionSection(
            icon: LucideIcons.eye,
            title: 'Accessibility Service',
            description:
                'Gentleman uses Accessibility Service to detect when you\'re inside a supported app like WhatsApp or Instagram. '
                'This allows us to monitor for voice and video call buttons.',
            granted: permissions.accessibilityEnabled,
            actionLabel: permissions.accessibilityEnabled ? 'Granted' : 'Open Settings',
            onAction: permissions.isLoading
                ? null
                : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
            delayMs: 0,
          ),
          const SizedBox(height: 12),
          _PermissionSection(
            icon: LucideIcons.layers,
            title: 'Overlay Permission',
            description:
                'Overlay permission allows Gentleman to show the "Hold to Confirm" dialog on top of other apps '
                'when a call button is pressed, preventing accidental calls.',
            granted: permissions.overlayEnabled,
            actionLabel: permissions.overlayEnabled ? 'Granted' : 'Open Settings',
            onAction: permissions.isLoading
                ? null
                : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
            delayMs: 100,
          ),
          const SizedBox(height: 12),
          _PermissionSection(
            icon: LucideIcons.batteryFull,
            title: 'Battery Optimization',
            description:
                'Disabling battery optimization helps Gentleman stay active in the background '
                'so it can always protect you when needed.',
            granted: permissions.batteryOptimizationDisabled,
            actionLabel: permissions.batteryOptimizationDisabled ? 'Granted' : 'Open Settings',
            onAction: permissions.isLoading
                ? null
                : () => ref.read(permissionProvider.notifier).openBatterySettings(),
            delayMs: 200,
          ),
          const SizedBox(height: 24),
          Card(
            color: cs.primaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(LucideIcons.shield, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All data stays on your device. '
                      'No network access. No tracking. No accounts.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final String actionLabel;
  final VoidCallback? onAction;
  final int delayMs;

  const _PermissionSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.actionLabel,
    this.onAction,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (granted ? Colors.green : cs.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: granted ? Colors.green : cs.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: granted ? Colors.green.withValues(alpha: 0.12) : cs.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    granted ? 'Granted' : 'Required',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: granted ? Colors.green : cs.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: granted ? null : onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: delayMs));
  }
}
