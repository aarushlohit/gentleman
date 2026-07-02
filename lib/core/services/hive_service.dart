import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../models/protected_app.dart';
import '../models/protection_event.dart';

/// Wraps Hive initialization and box access.
class HiveService {
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AppProtectionStatusAdapter());
    Hive.registerAdapter(ProtectedAppAdapter());
    Hive.registerAdapter(InteractionTypeAdapter());
    Hive.registerAdapter(ProtectionResultAdapter());
    Hive.registerAdapter(ProtectionEventAdapter());

    // Open boxes
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
    await Hive.openBox<ProtectionEvent>(AppConstants.statisticsBox);
    await Hive.openBox<ProtectedApp>(AppConstants.rulesBox);
  }

  Box<dynamic> get settingsBox => Hive.box<dynamic>(AppConstants.settingsBox);
  Box<ProtectionEvent> get statisticsBox => Hive.box<ProtectionEvent>(AppConstants.statisticsBox);
  Box<ProtectedApp> get rulesBox => Hive.box<ProtectedApp>(AppConstants.rulesBox);

  // ─── Settings Helpers ───
  T getSetting<T>(String key, T defaultValue) {
    return settingsBox.get(key, defaultValue: defaultValue) as T;
  }

  Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  // ─── Statistics Helpers ───
  Future<void> addProtectionEvent(ProtectionEvent event) async {
    await statisticsBox.add(event);
  }

  List<ProtectionEvent> getAllEvents() {
    return statisticsBox.values.toList();
  }

  List<ProtectionEvent> getEventsForDay(DateTime day) {
    return statisticsBox.values.where((e) {
      return e.timestamp.year == day.year &&
          e.timestamp.month == day.month &&
          e.timestamp.day == day.day;
    }).toList();
  }

  List<ProtectionEvent> getEventsForWeek() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return statisticsBox.values.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }

  Future<void> clearStatistics() async {
    await statisticsBox.clear();
  }

  // ─── Rules Helpers ───
  ProtectedApp? getRule(String packageName) {
    return rulesBox.get(packageName);
  }

  Future<void> saveRule(ProtectedApp app) async {
    await rulesBox.put(app.packageName, app);
  }

  List<ProtectedApp> getAllRules() {
    return rulesBox.values.toList();
  }

  Future<void> initDefaultRules() async {
    if (rulesBox.isEmpty) {
      await saveRule(ProtectedApp.whatsapp());
      await saveRule(ProtectedApp.instagram());
    }
  }
}

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final hiveInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(hiveServiceProvider);
  await service.init();
  await service.initDefaultRules();
});
