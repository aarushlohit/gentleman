import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/models/protection_event.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/utils/app_icons.dart';
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
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        elevation: 0,
        backgroundColor: cs.surface,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.read(statisticsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Stat Counters Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _buildAppleStatBox(
                    context,
                    icon: LucideIcons.shieldAlert,
                    color: Colors.green,
                    value: '${stats.todayCount}',
                    label: 'Today',
                  ),
                  const SizedBox(width: 8),
                  _buildAppleStatBox(
                    context,
                    icon: LucideIcons.calendar,
                    color: Colors.blue,
                    value: '${stats.weekCount}',
                    label: 'This Week',
                  ),
                  const SizedBox(width: 8),
                  _buildAppleStatBox(
                    context,
                    icon: LucideIcons.barChart3,
                    color: Colors.orange,
                    value: '${stats.totalCount}',
                    label: 'Total Saved',
                  ),
                ],
              ),
            ),
          ),

          // Average Hold Time (Apple Style Row)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.clock, color: cs.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stats.avgHoldDuration.toInt()} ms',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Average hold confirmation time',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            ),
          ),

          // Per App Breakdown (Grouped Card)
          if (stats.totalCount > 0) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'PROTECTION BY APP'),
            ),
            SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: [
                    if (stats.whatsappCount > 0) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(LucideIcons.messageCircle, size: 16, color: Colors.green),
                        ),
                        title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        trailing: Text(
                          '${stats.whatsappCount} blocked',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                      if (stats.instagramCount > 0) const Divider(height: 0.5, indent: 60),
                    ],
                    if (stats.instagramCount > 0)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.pink.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(LucideIcons.camera, size: 16, color: Colors.pink),
                        ),
                        title: const Text('Instagram', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        trailing: Text(
                          '${stats.instagramCount} blocked',
                          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurfaceVariant, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // Recent Activity Header
          SliverToBoxAdapter(
            child: _buildSectionHeader(context, 'RECENT ACTIVITY LOGS'),
          ),

          // Empty state
          if (stats.recentEvents.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 40, color: cs.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(
                      'All quiet on the shield front',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Protection triggers will show up here',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

          // Recent Activity List (Grouped inside a single Card)
          if (stats.recentEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: Card(
                child: Column(
                  children: List.generate(stats.recentEvents.length, (index) {
                    final event = stats.recentEvents[index];
                    final isLast = index == stats.recentEvents.length - 1;
                    final isBlocked = event.result == ProtectionResult.blocked;
                    final appColor = AppIcons.colorForPackage(event.packageName);

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: appColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(AppIcons.iconForPackage(event.packageName), color: appColor, size: 18),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.appName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (isBlocked ? Colors.green : cs.error).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isBlocked ? 'Blocked' : 'Allowed',
                                  style: TextStyle(
                                    color: isBlocked ? Colors.green : cs.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      event.interactionType == InteractionType.videoCall
                                          ? LucideIcons.video
                                          : LucideIcons.phone,
                                      size: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.interactionLabel,
                                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                Text(
                                  AppDateUtils.timeAgo(event.timestamp),
                                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isLast) const Divider(height: 0.5, indent: 64),
                      ],
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 350.ms),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildAppleStatBox(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
