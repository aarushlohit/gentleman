import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_service.dart';
import 'platform_channel_service.dart';

/// Aggregated permission/permission-like status.
class PermissionState {
  final bool accessibilityEnabled;
  final bool overlayEnabled;
  final bool serviceRunning;
  final bool isLoading;

  const PermissionState({
    this.accessibilityEnabled = false,
    this.overlayEnabled = false,
    this.serviceRunning = false,
    this.isLoading = true,
  });

  bool get allGranted => accessibilityEnabled && overlayEnabled;

  PermissionState copyWith({
    bool? accessibilityEnabled,
    bool? overlayEnabled,
    bool? serviceRunning,
    bool? isLoading,
  }) {
    return PermissionState(
      accessibilityEnabled: accessibilityEnabled ?? this.accessibilityEnabled,
      overlayEnabled: overlayEnabled ?? this.overlayEnabled,
      serviceRunning: serviceRunning ?? this.serviceRunning,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PermissionNotifier extends StateNotifier<PermissionState> {
  final PlatformChannelService _platform;

  PermissionNotifier(this._platform, HiveService _hive) : super(const PermissionState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final results = await Future.wait([
      _platform.isAccessibilityEnabled(),
      _platform.isOverlayEnabled(),
      _platform.isServiceRunning(),
    ]);
    state = PermissionState(
      accessibilityEnabled: results[0],
      overlayEnabled: results[1],
      serviceRunning: results[2],
      isLoading: false,
    );
  }

  Future<void> openAccessibilitySettings() async {
    await _platform.openAccessibilitySettings();
  }

  Future<void> openOverlaySettings() async {
    await _platform.openOverlaySettings();
  }

  Future<void> openBatterySettings() async {
    await _platform.openBatterySettings();
  }
}

final permissionProvider = StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier(
    ref.read(platformChannelServiceProvider),
    ref.read(hiveServiceProvider),
  );
});
