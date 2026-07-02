import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/protected_apps_provider.dart';
import '../../../core/utils/app_icons.dart';

class ProtectedAppsPage extends ConsumerWidget {
  const ProtectedAppsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final apps = ref.watch(protectedAppsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Protected Apps'),
        elevation: 0,
        backgroundColor: cs.surface,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: apps.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.smartphone, size: 64, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No apps configured', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              physics: const BouncingScrollPhysics(),
              children: [
                Card(
                  child: Column(
                    children: List.generate(apps.length, (index) {
                      final app = apps[index];
                      final isLast = index == apps.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    app.packageName,
                                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                  ),
                                  trailing: Switch.adaptive(
                                    value: app.isEnabled,
                                    activeTrackColor: Colors.green,
                                    onChanged: (v) {
                                      ref.read(protectedAppsProvider.notifier).toggleApp(app.packageName);
                                    },
                                  ),
                                ),
                                if (app.isEnabled)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(68, 4, 16, 8),
                                    child: Row(
                                      children: [
                                        _buildTypeToggle(
                                          context: context,
                                          label: 'Voice Protection',
                                          icon: LucideIcons.phone,
                                          active: app.voiceCallProtected,
                                          onTap: () {
                                            ref.read(protectedAppsProvider.notifier).toggleVoiceCall(app.packageName);
                                          },
                                        ),
                                        const SizedBox(width: 12),
                                        _buildTypeToggle(
                                          context: context,
                                          label: 'Video Protection',
                                          icon: LucideIcons.video,
                                          active: app.videoCallProtected,
                                          onTap: () {
                                            ref.read(protectedAppsProvider.notifier).toggleVideoCall(app.packageName);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 0.5, indent: 64),
                        ],
                      );
                    }),
                  ),
                ).animate().fadeIn(duration: 350.ms),
              ],
            ),
    );
  }

  Widget _buildTypeToggle({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = active ? Colors.green : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.green.withValues(alpha: 0.1) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? Colors.green.withValues(alpha: 0.2) : cs.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: activeColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Protected Apps'),
        content: const Text(
          'Enable protection for supported apps. Gentleman will monitor for voice and video call interactions and require you to hold the call button before proceeding.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }
}
