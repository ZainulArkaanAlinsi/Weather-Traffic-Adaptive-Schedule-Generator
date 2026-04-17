// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      homeLocation: fields[0] as String,
      workStartTime: fields[1] as String,
      workEndTime: fields[2] as String,
      preferredBreakStart: fields[3] as String,
      preferredBreakDuration: fields[4] as int,
      wakeUpTime: fields[5] as String,
      cityName: fields[6] as String,
      apiKeyOpenWeather: fields[7] as String?,
      apiKeyGoogleMaps: fields[8] as String?,
      isNotificationEnabled: fields[9] as bool,
      apiKeyGemini: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.homeLocation)
      ..writeByte(1)
      ..write(obj.workStartTime)
      ..writeByte(2)
      ..write(obj.workEndTime)
      ..writeByte(3)
      ..write(obj.preferredBreakStart)
      ..writeByte(4)
      ..write(obj.preferredBreakDuration)
      ..writeByte(5)
      ..write(obj.wakeUpTime)
      ..writeByte(6)
      ..write(obj.cityName)
      ..writeByte(7)
      ..write(obj.apiKeyOpenWeather)
      ..writeByte(8)
      ..write(obj.apiKeyGoogleMaps)
      ..writeByte(9)
      ..write(obj.isNotificationEnabled)
      ..writeByte(10)
      ..write(obj.apiKeyGemini);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
