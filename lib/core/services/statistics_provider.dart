import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/protection_event.dart';
import '../services/hive_service.dart';

class StatisticsState {
  final int todayCount;
  final int weekCount;
  final int totalCount;
  final int whatsappCount;
  final int instagramCount;
  final double avgHoldDuration;
  final ProtectionEvent? lastEvent;

  const StatisticsState({
    this.todayCount = 0,
    this.weekCount = 0,
    this.totalCount = 0,
    this.whatsappCount = 0,
    this.instagramCount = 0,
    this.avgHoldDuration = 0,
    this.lastEvent,
  });
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final HiveService _hive;

  StatisticsNotifier(this._hive) : super(const StatisticsState()) {
    refresh();
  }

  Future<void> refresh() async {
    final all = _hive.getAllEvents();
    final today = _hive.getEventsForDay(DateTime.now());
    final week = _hive.getEventsForWeek();

    final blocked = all.where((e) => e.result == ProtectionResult.blocked).toList();
    final whatsappBlocked = blocked.where((e) => e.packageName == 'com.whatsapp').length;
    final instagramBlocked = blocked.where((e) => e.packageName == 'com.instagram.android').length;

    double avgHold = 0;
    if (blocked.isNotEmpty) {
      avgHold = blocked.map((e) => e.holdDurationMs).reduce((a, b) => a + b) / blocked.length;
    }

    state = StatisticsState(
      todayCount: today.where((e) => e.result == ProtectionResult.blocked).length,
      weekCount: week.where((e) => e.result == ProtectionResult.blocked).length,
      totalCount: blocked.length,
      whatsappCount: whatsappBlocked,
      instagramCount: instagramBlocked,
      avgHoldDuration: avgHold,
      lastEvent: all.isNotEmpty ? all.last : null,
    );
  }

  Future<void> recordEvent(ProtectionEvent event) async {
    await _hive.addProtectionEvent(event);
    await refresh();
  }

  Future<void> clearAll() async {
    await _hive.clearStatistics();
    await refresh();
  }
}

final statisticsProvider = StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier(ref.read(hiveServiceProvider));
});
