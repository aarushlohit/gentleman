import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

/// Platform channel bridge to native Android.
class PlatformChannelService {
  static const _channel = MethodChannel(AppConstants.channelName);

  Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(AppConstants.methodIsAccessibilityEnabled);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isOverlayEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(AppConstants.methodIsOverlayEnabled);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>(AppConstants.methodOpenAccessibilitySettings);
    } on PlatformException {
      // Silently fail — user can navigate manually.
    }
  }

  Future<void> openOverlaySettings() async {
    try {
      await _channel.invokeMethod<void>(AppConstants.methodOpenOverlaySettings);
    } on PlatformException {
      // Silently fail.
    }
  }

  Future<void> openBatterySettings() async {
    try {
      await _channel.invokeMethod<void>(AppConstants.methodOpenBatterySettings);
    } on PlatformException {
      // Silently fail.
    }
  }

  Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod<bool>(AppConstants.methodIsServiceRunning);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<String?> getForegroundApp() async {
    try {
      final result = await _channel.invokeMethod<String>(AppConstants.methodGetForegroundApp);
      return result;
    } on PlatformException {
      return null;
    }
  }
}

final platformChannelServiceProvider = Provider<PlatformChannelService>((ref) {
  return PlatformChannelService();
});
