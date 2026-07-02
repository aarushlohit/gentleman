import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'dart:async';
import '../models/protection_event.dart' as models;

/// Platform channel bridge to native Android.
class PlatformChannelService {
  static const _channel = MethodChannel(AppConstants.channelName);

  final StreamController<models.ProtectionEvent> _eventController = StreamController.broadcast();

  PlatformChannelService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == AppConstants.methodOnProtectionEvent) {
        try {
          final args = call.arguments as Map<dynamic, dynamic>?;
          if (args != null) {
            final pkg = args['package'] as String? ?? '';
            final interaction = args['interaction'] as String? ?? 'voice';
            final interactionType = interaction == 'video' ? models.InteractionType.videoCall : models.InteractionType.voiceCall;
            final event = models.ProtectionEvent(
              packageName: pkg,
              interactionType: interactionType,
              result: models.ProtectionResult.allowed,
              timestamp: DateTime.now(),
              holdDurationMs: 0,
            );
            _eventController.add(event);
          }
        } catch (_) {}
      } else if (call.method == AppConstants.methodOnProtectionDecision) {
        try {
          final args = call.arguments as Map<dynamic, dynamic>?;
          if (args != null) {
            final pkg = args['package'] as String? ?? '';
            final interaction = args['interaction'] as String? ?? 'voice';
            final resultStr = args['result'] as String? ?? 'blocked';
            final interactionType = interaction == 'video' ? models.InteractionType.videoCall : models.InteractionType.voiceCall;
            final result = resultStr == 'allowed' ? models.ProtectionResult.allowed : models.ProtectionResult.blocked;
            final event = models.ProtectionEvent(
              packageName: pkg,
              interactionType: interactionType,
              result: result,
              timestamp: DateTime.now(),
              holdDurationMs: 0,
            );
            _eventController.add(event);
          }
        } catch (_) {}
      }
    });
  }

  Stream<models.ProtectionEvent> get onProtectionEvent => _eventController.stream;

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
