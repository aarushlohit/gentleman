import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/models/protection_event.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/settings_provider.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_widgets.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

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
              title: Text('Settings'),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PremiumPill(
                      label: 'Hold duration ${settings.holdDurationMs}ms',
                      color: AppColors.info,
                      icon: LucideIcons.timerReset,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Shape the experience without compromising the core safety contract.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34, height: 0.98),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Interaction',
                title: 'Confirmation timing',
                subtitle: 'Shorter hold durations feel faster. Longer ones reduce accidental intent even further.',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<int>(
                      segments: AppConstants.holdDurationOptions
                          .map((duration) => ButtonSegment(value: duration, label: Text('${duration}ms')))
                          .toList(),
                      selected: {settings.holdDurationMs},
                      onSelectionChanged: (value) {
                        ref.read(appSettingsProvider.notifier).setHoldDuration(value.first);
                      },
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: settings.holdDurationMs / 2000,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Behavior',
                title: 'Protection preferences',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    _SettingsToggleRow(
                      title: 'Vibration feedback',
                      subtitle: 'Add haptics when a call action is intercepted.',
                      value: settings.vibrationEnabled,
                      icon: LucideIcons.vibrate,
                      onChanged: (value) => ref.read(appSettingsProvider.notifier).setVibration(value),
                    ),
                    const SizedBox(height: 20),
                    _SettingsToggleRow(
                      title: 'Overlay animations',
                      subtitle: 'Keep transitions polished when the shield appears and dismisses.',
                      value: settings.animationEnabled,
                      icon: LucideIcons.sparkles,
                      onChanged: (value) => ref.read(appSettingsProvider.notifier).setAnimation(value),
                    ),
                    const SizedBox(height: 20),
                    _SettingsToggleRow(
                      title: 'Dark mode',
                      subtitle: 'Use the darker premium palette across the app shell.',
                      value: settings.darkMode,
                      icon: LucideIcons.moonStar,
                      onChanged: (value) => ref.read(appSettingsProvider.notifier).setDarkMode(value),
                    ),
                    const SizedBox(height: 20),
                    _SettingsToggleRow(
                      title: 'Dynamic colors',
                      subtitle: 'Blend selected surfaces with the system accent where supported.',
                      value: settings.dynamicColors,
                      icon: LucideIcons.palette,
                      onChanged: (value) => ref.read(appSettingsProvider.notifier).setDynamicColors(value),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Data',
                title: 'Logs and recovery',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    _ActionRow(
                      title: 'Export protection logs',
                      subtitle: 'Share the event history as CSV for debugging or analysis.',
                      icon: LucideIcons.fileDown,
                      accent: AppColors.info,
                      onTap: () => _exportCsv(context, ref),
                    ),
                    const SizedBox(height: 18),
                    _ActionRow(
                      title: 'Reset statistics',
                      subtitle: 'Permanently delete the local event history.',
                      icon: LucideIcons.trash2,
                      accent: AppColors.danger,
                      onTap: () => _confirmReset(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'About',
                title: 'Build information',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                onTap: () => context.push(RoutePaths.about),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(LucideIcons.info, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gentleman ${AppConstants.appVersion}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Read the project context and product notes.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.chevronRight, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    try {
      final hive = ref.read(hiveServiceProvider);
      final events = hive.getAllEvents();

      if (events.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No events to export')));
        }
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln('timestamp,app,package,call_type,result,hold_duration_ms');
      for (final ProtectionEvent event in events) {
        buffer.writeln(
          '${event.timestamp.toIso8601String()},'
          '"${event.appName}",'
          '"${event.packageName}",'
          '${event.interactionLabel},'
          '${event.result.name},'
          '${event.holdDurationMs}',
        );
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/gentleman_logs.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Gentleman Protection Logs',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $error')));
      }
    }
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset statistics'),
        content: const Text('This permanently clears the local protection history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(statisticsProvider.notifier).clearAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Statistics reset')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _SettingsToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
