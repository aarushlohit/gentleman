import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/settings_provider.dart';
import '../../../core/services/statistics_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionCard(
            title: 'Hold Duration',
            subtitle: 'How long to hold the call button before it registers',
            delayMs: 0,
            child: Column(
              children: [
                SegmentedButton<int>(
                  segments: AppConstants.holdDurationOptions.map((d) {
                    return ButtonSegment(value: d, label: Text('${d}ms'));
                  }).toList(),
                  selected: {settings.holdDurationMs},
                  onSelectionChanged: (v) {
                    ref.read(appSettingsProvider.notifier).setHoldDuration(v.first);
                  },
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: settings.holdDurationMs / 2000,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Protection Features',
            delayMs: 80,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibration'),
                  subtitle: const Text('Haptic feedback on interception'),
                  value: settings.vibrationEnabled,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setVibration(v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Animations'),
                  subtitle: const Text('Show overlay animations'),
                  value: settings.animationEnabled,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setAnimation(v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  value: settings.darkMode,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setDarkMode(v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dynamic Colors'),
                  subtitle: const Text('Use system accent color'),
                  value: settings.dynamicColors,
                  onChanged: (v) => ref.read(appSettingsProvider.notifier).setDynamicColors(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Data',
            delayMs: 160,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(LucideIcons.trash2, color: cs.error),
                  title: const Text('Reset Statistics'),
                  subtitle: const Text('Clear all protection history'),
                  onTap: () => _confirmReset(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.fileDown),
                  title: const Text('Export Logs'),
                  subtitle: const Text('Save protection log as CSV'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'About',
            delayMs: 240,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(LucideIcons.info),
              title: const Text('About Gentleman'),
              subtitle: const Text('Version ${AppConstants.appVersion}'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => context.push(RoutePaths.about),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text('This will permanently delete all protection history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(statisticsProvider.notifier).clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistics reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final int delayMs;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delayMs));
  }
}
