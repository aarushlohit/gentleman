import 'package:hive/hive.dart';

part 'protection_event.g.dart';

@HiveType(typeId: 2)
enum InteractionType {
  @HiveField(0)
  voiceCall,

  @HiveField(1)
  videoCall,
}

@HiveType(typeId: 3)
enum ProtectionResult {
  @HiveField(0)
  allowed,

  @HiveField(1)
  blocked,
}

@HiveType(typeId: 4)
class ProtectionEvent extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final InteractionType interactionType;

  @HiveField(2)
  final ProtectionResult result;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final int holdDurationMs;

  ProtectionEvent({
    required this.packageName,
    required this.interactionType,
    required this.result,
    required this.timestamp,
    required this.holdDurationMs,
  });

  String get appName {
    switch (packageName) {
      case 'com.whatsapp':
        return 'WhatsApp';
      case 'com.instagram.android':
        return 'Instagram';
      default:
        return packageName;
    }
  }

  String get interactionLabel {
    switch (interactionType) {
      case InteractionType.voiceCall:
        return 'Voice Call';
      case InteractionType.videoCall:
        return 'Video Call';
    }
  }
}
