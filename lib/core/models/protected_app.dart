import 'package:hive/hive.dart';

part 'protected_app.g.dart';

@HiveType(typeId: 0)
enum AppProtectionStatus {
  @HiveField(0)
  enabled,

  @HiveField(1)
  disabled,
}

@HiveType(typeId: 1)
class ProtectedApp extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String displayName;

  @HiveField(2)
  AppProtectionStatus status;

  @HiveField(3)
  bool voiceCallProtected;

  @HiveField(4)
  bool videoCallProtected;

  ProtectedApp({
    required this.packageName,
    required this.displayName,
    this.status = AppProtectionStatus.enabled,
    this.voiceCallProtected = true,
    this.videoCallProtected = true,
  });

  bool get isEnabled => status == AppProtectionStatus.enabled;

  ProtectedApp copyWith({
    AppProtectionStatus? status,
    bool? voiceCallProtected,
    bool? videoCallProtected,
  }) {
    return ProtectedApp(
      packageName: packageName,
      displayName: displayName,
      status: status ?? this.status,
      voiceCallProtected: voiceCallProtected ?? this.voiceCallProtected,
      videoCallProtected: videoCallProtected ?? this.videoCallProtected,
    );
  }

  static ProtectedApp whatsapp() => const ProtectedApp(
        packageName: 'com.whatsapp',
        displayName: 'WhatsApp',
      );

  static ProtectedApp instagram() => const ProtectedApp(
        packageName: 'com.instagram.android',
        displayName: 'Instagram',
      );
}
