import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/utils/date_utils.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statisticsProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.read(statisticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              _StatCard(
                icon: LucideIcons.shieldOff,
                label: 'Today',
                value: '${stats.todayCount}',
                color: Colors.green,
                delayMs: 0,
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: LucideIcons.calendar,
                label: 'This Week',
                value: '${stats.weekCount}',
                color: cs.primary,
                delayMs: 80,
              ),
              const SizedBox(width: 8),
              _StatCard(
                icon: LucideIcons.barChart3,
                label: 'Total',
                value: '${stats.totalCount}',
                color: Colors.orange,
                delayMs: 160,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average Hold Duration', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 32, color: cs.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${stats.avgHoldDuration.toInt()} ms',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 240.ms),
          if (stats.totalCount > 0) ...[
            const SizedBox(height: 24),
            Text(
              'Per App',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            ...[
              if (stats.whatsappCount > 0)
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.messageCircle, size: 18, color: Colors.green),
                    ),
                    title: const Text('WhatsApp'),
                    trailing: Text(
                      '${stats.whatsappCount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              if (stats.instagramCount > 0)
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.camera, size: 18, color: Colors.pink),
                    ),
                    title: const Text('Instagram'),
                    trailing: Text(
                      '${stats.instagramCount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
            ],
          ],
          if (stats.lastEvent != null) ...[
            const SizedBox(height: 24),
            Card(
              color: cs.primaryContainer.withValues(alpha: 0.15),
              child: ListTile(
                leading: Icon(LucideIcons.history, color: cs.primary),
                title: Text('Last event: ${stats.lastEvent!.interactionLabel}'),
                subtitle: Text(
                  '${stats.lastEvent!.appName} - ${AppDateUtils.timeAgo(stats.lastEvent!.timestamp)}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delayMs;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delayMs));
  }
}
