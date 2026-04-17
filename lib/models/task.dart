import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

enum Priority {
  high,
  medium,
  low,
}

enum WeatherConstraint {
  noPreference,
  noRain,
  noExtremeHeat,
  noStorm,
}

enum TrafficConstraint {
  noPreference,
  rescheduleIfTrafficHeavy,
  switchToZoom,
}

enum TaskStatus {
  pending,
  scheduled,
  rescheduled,
  completed,
}

@HiveType(typeId: 0)
class Task extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int duration;

  @HiveField(3)
  final Priority priority;

  @HiveField(4)
  final DateTime? deadline;

  @HiveField(5)
  final bool isOutdoor;

  @HiveField(6)
  final WeatherConstraint weatherConstraint;

  @HiveField(7)
  final TrafficConstraint trafficConstraint;

  @HiveField(8)
  final String? location;

  @HiveField(9)
  final String? destination;

  @HiveField(10)
  final DateTime? scheduledTime;

  @HiveField(11)
  final TaskStatus status;

  @HiveField(12)
  final String? rescheduleReason;

  Task({
    String? id,
    required this.title,
    required this.duration,
    required this.priority,
    this.deadline,
    required this.isOutdoor,
    required this.weatherConstraint,
    required this.trafficConstraint,
    this.location,
    this.destination,
    this.scheduledTime,
    TaskStatus? status,
    this.rescheduleReason,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? TaskStatus.pending;

  Task copyWith({
    String? id,
    String? title,
    int? duration,
    Priority? priority,
    DateTime? deadline,
    bool? isOutdoor,
    WeatherConstraint? weatherConstraint,
    TrafficConstraint? trafficConstraint,
    String? location,
    String? destination,
    DateTime? scheduledTime,
    TaskStatus? status,
    String? rescheduleReason,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      weatherConstraint: weatherConstraint ?? this.weatherConstraint,
      trafficConstraint: trafficConstraint ?? this.trafficConstraint,
      location: location ?? this.location,
      destination: destination ?? this.destination,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        duration,
        priority,
        deadline,
        isOutdoor,
        weatherConstraint,
        trafficConstraint,
        location,
        destination,
        scheduledTime,
        status,
        rescheduleReason,
      ];
}
