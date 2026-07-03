import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/models/protection_event.dart';
import '../../../core/services/statistics_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/premium_widgets.dart';

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
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: const Text('Statistics'),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw),
                  onPressed: () => ref.read(statisticsProvider.notifier).refresh(),
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
                      label: stats.totalCount == 0 ? 'No intercepts yet' : '${stats.totalCount} protected moments logged',
                      color: stats.totalCount == 0 ? cs.onSurfaceVariant : AppColors.success,
                      icon: stats.totalCount == 0 ? LucideIcons.clock3 : LucideIcons.shield,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Your protection history, rendered like a control room instead of a spreadsheet.',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 36,
                        height: 0.96,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Blocked attempts, app distribution, and confirmation rhythm all live here.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Today',
                        value: '${stats.todayCount}',
                        icon: LucideIcons.sunMedium,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'This week',
                        value: '${stats.weekCount}',
                        icon: LucideIcons.calendarDays,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Average hold',
                        value: '${stats.avgHoldDuration.toInt()}ms',
                        icon: LucideIcons.timer,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Breakdown',
                title: 'Where protection is working',
              ),
            ),
            SliverToBoxAdapter(
              child: PremiumPanel(
                child: Column(
                  children: [
                    _BreakdownRow(
                      appName: 'WhatsApp',
                      icon: LucideIcons.messageCircle,
                      color: AppColors.whatsapp,
                      count: stats.whatsappCount,
                      total: stats.totalCount,
                    ),
                    Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 24),
                    _BreakdownRow(
                      appName: 'Instagram',
                      icon: LucideIcons.camera,
                      color: AppColors.instagram,
                      count: stats.instagramCount,
                      total: stats.totalCount,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: PremiumSectionTitle(
                eyebrow: 'Timeline',
                title: 'Recent activity',
                subtitle: 'Each entry records the app, the interaction type, and whether Gentleman blocked or allowed it.',
              ),
            ),
            if (stats.recentEvents.isEmpty)
              SliverToBoxAdapter(
                child: PremiumPanel(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(LucideIcons.shieldCheck, color: cs.primary, size: 28),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'The log is quiet for now.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'As soon as a call is intercepted, the event history will start building here.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (stats.recentEvents.isNotEmpty)
              SliverToBoxAdapter(
                child: PremiumPanel(
                  child: Column(
                    children: [
                      for (var index = 0; index < stats.recentEvents.length; index++) ...[
                        _EventRow(event: stats.recentEvents[index]),
                        if (index != stats.recentEvents.length - 1)
                          Divider(color: cs.outlineVariant.withValues(alpha: 0.75), height: 24),
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

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumPanel(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String appName;
  final IconData icon;
  final Color color;
  final int count;
  final int total;

  const _BreakdownRow({
    required this.appName,
    required this.icon,
    required this.color,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final share = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    '$count blocked interactions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text('${(share * 100).round()}%', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: share,
            minHeight: 9,
            color: color,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final ProtectionEvent event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appColor = AppIcons.colorForPackage(event.packageName);
    final blocked = event.result == ProtectionResult.blocked;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: appColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(AppIcons.iconForPackage(event.packageName), color: appColor, size: 20),
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
                      event.appName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  PremiumPill(
                    label: blocked ? 'Blocked' : 'Allowed',
                    color: blocked ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                event.interactionLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    event.interactionType == InteractionType.videoCall ? LucideIcons.video : LucideIcons.phone,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    AppDateUtils.timeAgo(event.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
