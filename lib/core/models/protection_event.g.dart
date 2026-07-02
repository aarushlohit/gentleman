// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protection_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InteractionTypeAdapter extends TypeAdapter<InteractionType> {
  @override
  final int typeId = 2;

  @override
  InteractionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InteractionType.voiceCall;
      case 1:
        return InteractionType.videoCall;
      default:
        return InteractionType.voiceCall;
    }
  }

  @override
  void write(BinaryWriter writer, InteractionType obj) {
    switch (obj) {
      case InteractionType.voiceCall:
        writer.writeByte(0);
        break;
      case InteractionType.videoCall:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InteractionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtectionResultAdapter extends TypeAdapter<ProtectionResult> {
  @override
  final int typeId = 3;

  @override
  ProtectionResult read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProtectionResult.allowed;
      case 1:
        return ProtectionResult.blocked;
      default:
        return ProtectionResult.allowed;
    }
  }

  @override
  void write(BinaryWriter writer, ProtectionResult obj) {
    switch (obj) {
      case ProtectionResult.allowed:
        writer.writeByte(0);
        break;
      case ProtectionResult.blocked:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProtectionEventAdapter extends TypeAdapter<ProtectionEvent> {
  @override
  final int typeId = 4;

  @override
  ProtectionEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ProtectionEvent(
      packageName: fields[0] as String,
      interactionType: fields[1] as InteractionType,
      result: fields[2] as ProtectionResult,
      timestamp: fields[3] as DateTime,
      holdDurationMs: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProtectionEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.interactionType)
      ..writeByte(2)
      ..write(obj.result)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.holdDurationMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtectionEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
