import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/protected_app.dart';
import '../services/hive_service.dart';

class ProtectedAppsNotifier extends StateNotifier<List<ProtectedApp>> {
  final HiveService _hive;

  ProtectedAppsNotifier(this._hive) : super([]) {
    _load();
  }

  void _load() {
    state = _hive.getAllRules();
  }

  Future<void> toggleApp(String packageName) async {
    final app = _hive.getRule(packageName);
    if (app == null) return;

    final updated = app.copyWith(
      status: app.isEnabled ? AppProtectionStatus.disabled : AppProtectionStatus.enabled,
    );
    await _hive.saveRule(updated);
    _load();
  }

  Future<void> toggleVoiceCall(String packageName) async {
    final app = _hive.getRule(packageName);
    if (app == null) return;

    final updated = app.copyWith(voiceCallProtected: !app.voiceCallProtected);
    await _hive.saveRule(updated);
    _load();
  }

  Future<void> toggleVideoCall(String packageName) async {
    final app = _hive.getRule(packageName);
    if (app == null) return;

    final updated = app.copyWith(videoCallProtected: !app.videoCallProtected);
    await _hive.saveRule(updated);
    _load();
  }

  ProtectedApp? getApp(String packageName) {
    return _hive.getRule(packageName);
  }
}

final protectedAppsProvider = StateNotifierProvider<ProtectedAppsNotifier, List<ProtectedApp>>((ref) {
  return ProtectedAppsNotifier(ref.read(hiveServiceProvider));
});
