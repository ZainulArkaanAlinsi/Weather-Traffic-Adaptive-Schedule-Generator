// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleAdapter extends TypeAdapter<Schedule> {
  @override
  final int typeId = 1;

  @override
  Schedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Schedule(
      id: fields[0] as String?,
      date: fields[1] as DateTime,
      tasks: (fields[2] as List).cast<Task>(),
      totalHours: fields[3] as int,
      weatherForecast: fields[4] as String?,
      generatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Schedule obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.tasks)
      ..writeByte(3)
      ..write(obj.totalHours)
      ..writeByte(4)
      ..write(obj.weatherForecast)
      ..writeByte(5)
      ..write(obj.generatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
