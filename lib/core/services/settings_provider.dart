import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../services/hive_service.dart';
import '../services/platform_channel_service.dart';

/// App settings state.
class AppSettings {
  final int holdDurationMs;
  final bool vibrationEnabled;
  final bool animationEnabled;
  final bool darkMode;
  final bool dynamicColors;

  const AppSettings({
    this.holdDurationMs = AppConstants.defaultHoldDurationMs,
    this.vibrationEnabled = AppConstants.defaultVibrationEnabled,
    this.animationEnabled = AppConstants.defaultAnimationEnabled,
    this.darkMode = AppConstants.defaultDarkMode,
    this.dynamicColors = AppConstants.defaultDynamicColors,
  });

  AppSettings copyWith({
    int? holdDurationMs,
    bool? vibrationEnabled,
    bool? animationEnabled,
    bool? darkMode,
    bool? dynamicColors,
  }) {
    return AppSettings(
      holdDurationMs: holdDurationMs ?? this.holdDurationMs,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      animationEnabled: animationEnabled ?? this.animationEnabled,
      darkMode: darkMode ?? this.darkMode,
      dynamicColors: dynamicColors ?? this.dynamicColors,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final HiveService _hive;
  final PlatformChannelService _platform;

  AppSettingsNotifier(this._hive, this._platform) : super(const AppSettings()) {
    _load();
  }

  void _load() {
    state = AppSettings(
      holdDurationMs: _hive.getSetting('holdDurationMs', AppConstants.defaultHoldDurationMs),
      vibrationEnabled: _hive.getSetting('vibrationEnabled', AppConstants.defaultVibrationEnabled),
      animationEnabled: _hive.getSetting('animationEnabled', AppConstants.defaultAnimationEnabled),
      darkMode: _hive.getSetting('darkMode', AppConstants.defaultDarkMode),
      dynamicColors: _hive.getSetting('dynamicColors', AppConstants.defaultDynamicColors),
    );
  }

  Future<void> setHoldDuration(int ms) async {
    await _hive.setSetting('holdDurationMs', ms);
    await _platform.setHoldDurationMs(ms);
    state = state.copyWith(holdDurationMs: ms);
  }

  Future<void> setVibration(bool value) async {
    await _hive.setSetting('vibrationEnabled', value);
    state = state.copyWith(vibrationEnabled: value);
  }

  Future<void> setAnimation(bool value) async {
    await _hive.setSetting('animationEnabled', value);
    state = state.copyWith(animationEnabled: value);
  }

  Future<void> setDarkMode(bool value) async {
    await _hive.setSetting('darkMode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> setDynamicColors(bool value) async {
    await _hive.setSetting('dynamicColors', value);
    state = state.copyWith(dynamicColors: value);
  }

  Future<void> resetAll() async {
    await _hive.clearStatistics();
    state = const AppSettings();
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(
    ref.read(hiveServiceProvider),
    ref.read(platformChannelServiceProvider),
  );
});
