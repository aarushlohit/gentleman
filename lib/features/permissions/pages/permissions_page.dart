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

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Permissions'),
        elevation: 0,
        backgroundColor: cs.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // Apple Group 1: All System permissions in a single card
          Card(
            child: Column(
              children: [
                _buildApplePermissionTile(
                  context: context,
                  icon: LucideIcons.eye,
                  iconColor: Colors.blue,
                  title: 'Accessibility Service',
                  description: 'Used to monitor call click events in WhatsApp and Instagram to prevent accidental triggers.',
                  status: permissions.accessibilityEnabled,
                  onTap: permissions.isLoading
                      ? null
                      : () => ref.read(permissionProvider.notifier).openAccessibilitySettings(),
                ),
                const Divider(height: 0.5, indent: 56),
                _buildApplePermissionTile(
                  context: context,
                  icon: LucideIcons.layers,
                  iconColor: Colors.purple,
                  title: 'Overlay Permission',
                  description: 'Allows Gentleman to show the "Hold to Confirm" dialogue interface over WhatsApp or Instagram.',
                  status: permissions.overlayEnabled,
                  onTap: permissions.isLoading
                      ? null
                      : () => ref.read(permissionProvider.notifier).openOverlaySettings(),
                ),
                const Divider(height: 0.5, indent: 56),
                _buildApplePermissionTile(
                  context: context,
                  icon: LucideIcons.batteryFull,
                  iconColor: Colors.green,
                  title: 'Battery Optimization',
                  description: 'Allow background activity to guarantee the shielding engine is active when call buttons are clicked.',
                  status: permissions.batteryOptimizationDisabled,
                  onTap: permissions.isLoading
                      ? null
                      : () => ref.read(permissionProvider.notifier).openBatterySettings(),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: 24),

          // Apple Group 2: Privacy Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.shield, color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy First Design',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All configurations, names, and logs stay strictly on your local storage. Gentleman does not possess network permissions or use tracking code.',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
        ],
      ),
    );
  }

  Widget _buildApplePermissionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool status,
    required VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = status ? Colors.green : Colors.orange;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status ? 'Active' : 'Setup Required',
              style: TextStyle(
                color: activeColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ),
      trailing: status
          ? null
          : Icon(
              LucideIcons.chevronRight,
              color: cs.onSurfaceVariant,
              size: 16,
            ),
      onTap: status ? null : onTap,
    );
  }
}
