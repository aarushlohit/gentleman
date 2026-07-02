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
      appBar: AppBar(
        title: const Text('Protected Apps'),
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
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppIcons.colorForPackage(app.packageName).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                AppIcons.iconForPackage(app.packageName),
                                color: AppIcons.colorForPackage(app.packageName),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.displayName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    app.packageName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: app.isEnabled,
                              onChanged: (v) {
                                ref.read(protectedAppsProvider.notifier).toggleApp(app.packageName);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Block call types',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _CallTypeChip(
                              label: 'Voice Call',
                              icon: LucideIcons.phone,
                              active: app.voiceCallProtected,
                              onToggle: (v) {
                                ref.read(protectedAppsProvider.notifier).toggleVoiceCall(
                                      app.packageName,
                                    );
                              },
                            ),
                            const SizedBox(width: 8),
                            _CallTypeChip(
                              label: 'Video Call',
                              icon: LucideIcons.video,
                              active: app.videoCallProtected,
                              onToggle: (v) {
                                ref.read(protectedAppsProvider.notifier).toggleVideoCall(
                                      app.packageName,
                                    );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: index * 80),
                    );
              },
            ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Protected Apps'),
        content: Text(
          'Enable protection for supported apps. '
          'Gentleman will monitor for voice and video call interactions '
          'and require you to hold the call button before proceeding.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _CallTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final ValueChanged<bool> onToggle;

  const _CallTypeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: active,
      onSelected: onToggle,
      selectedColor: cs.primary.withValues(alpha: 0.15),
    );
  }
}
