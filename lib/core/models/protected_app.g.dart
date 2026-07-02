// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protected_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppProtectionStatusAdapter extends TypeAdapter<AppProtectionStatus> {
  @override
  final int typeId = 0;

  @override
  AppProtectionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppProtectionStatus.enabled;
      case 1:
        return AppProtectionStatus.disabled;
      default:
        return AppProtectionStatus.enabled;
    }
  }

  @override
  void write(BinaryWriter writer, AppProtectionStatus obj) {
    switch (obj) {
      case AppProtectionStatus.enabled:
        writer.writeByte(0);
        break;
      case AppProtectionStatus.disabled:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProtectionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtectedAppAdapter extends TypeAdapter<ProtectedApp> {
  @override
  final int typeId = 1;

  @override
  ProtectedApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ProtectedApp(
      packageName: fields[0] as String,
      displayName: fields[1] as String,
      status: fields[2] as AppProtectionStatus,
      voiceCallProtected: fields[3] as bool,
      videoCallProtected: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProtectedApp obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.voiceCallProtected)
      ..writeByte(4)
      ..write(obj.videoCallProtected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectedAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
