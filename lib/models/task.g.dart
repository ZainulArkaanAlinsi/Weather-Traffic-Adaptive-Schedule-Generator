// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String?,
      title: fields[1] as String,
      duration: fields[2] as int,
      priority: fields[3] as Priority,
      deadline: fields[4] as DateTime?,
      isOutdoor: fields[5] as bool,
      weatherConstraint: fields[6] as WeatherConstraint,
      trafficConstraint: fields[7] as TrafficConstraint,
      location: fields[8] as String?,
      destination: fields[9] as String?,
      scheduledTime: fields[10] as DateTime?,
      status: fields[11] as TaskStatus?,
      rescheduleReason: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.priority)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.isOutdoor)
      ..writeByte(6)
      ..write(obj.weatherConstraint)
      ..writeByte(7)
      ..write(obj.trafficConstraint)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.destination)
      ..writeByte(10)
      ..write(obj.scheduledTime)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.rescheduleReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
