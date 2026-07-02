import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform_channel_service.dart';
import 'hive_service.dart';
// models are referenced dynamically from the platform event stream; no direct type import required here.

/// Listens for native protection events and persists them via Hive.
class ProtectionEventService {
  final PlatformChannelService _platform;
  final HiveService _hive;
  StreamSubscription? _sub;

  ProtectionEventService(this._platform, this._hive) {
    _sub = _platform.onProtectionEvent.listen((event) async {
      await _hive.addProtectionEvent(event);
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}

final protectionEventServiceProvider = Provider<ProtectionEventService>((ref) {
  final platform = ref.read(platformChannelServiceProvider);
  final hive = ref.read(hiveServiceProvider);
  final svc = ProtectionEventService(platform, hive);
  ref.onDispose(() => svc.dispose());
  return svc;
});
