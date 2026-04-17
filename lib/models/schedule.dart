import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'task.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final List<Task> tasks;

  @HiveField(3)
  final int totalHours;

  @HiveField(4)
  final String? weatherForecast;

  @HiveField(5)
  final DateTime generatedAt;

  Schedule({
    String? id,
    required this.date,
    required this.tasks,
    required this.totalHours,
    this.weatherForecast,
    DateTime? generatedAt,
  })  : id = id ?? const Uuid().v4(),
        generatedAt = generatedAt ?? DateTime.now();

  Schedule copyWith({
    String? id,
    DateTime? date,
    List<Task>? tasks,
    int? totalHours,
    String? weatherForecast,
    DateTime? generatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      tasks: tasks ?? this.tasks,
      totalHours: totalHours ?? this.totalHours,
      weatherForecast: weatherForecast ?? this.weatherForecast,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        tasks,
        totalHours,
        weatherForecast,
        generatedAt,
      ];
}
