import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/schedule.dart';
import '../models/settings.dart';

class DatabaseService {
  static const String taskBoxName = 'tasks';
  static const String scheduleBoxName = 'schedules';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScheduleAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }

    await Hive.openBox<Task>(taskBoxName);
    await Hive.openBox<Schedule>(scheduleBoxName);
    await Hive.openBox<UserSettings>(settingsBoxName);
    await Hive.openBox('app_settings');
  }

  Box<Task> get taskBox => Hive.box<Task>(taskBoxName);
  Box<Schedule> get scheduleBox => Hive.box<Schedule>(scheduleBoxName);
  Box<UserSettings> get settingsBox => Hive.box<UserSettings>(settingsBoxName);

  // Task operations
  Future<void> addTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  List<Task> getAllTasks() {
    return taskBox.values.toList();
  }

  List<Task> getTasksByDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return taskBox.values.where((task) {
      if (task.scheduledTime == null) return false;
      final taskDate = DateTime(
        task.scheduledTime!.year,
        task.scheduledTime!.month,
        task.scheduledTime!.day,
      );
      return taskDate == normalizedDate;
    }).toList();
  }

  // Schedule operations
  Future<void> addSchedule(Schedule schedule) async {
    await scheduleBox.put(schedule.id, schedule);
  }

  Schedule? getScheduleByDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    try {
      return scheduleBox.values.firstWhere((schedule) {
        final scheduleDate = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
        );
        return scheduleDate == normalizedDate;
      });
    } catch (e) {
      return null;
    }
  }

  List<Schedule> getAllSchedules() {
    return scheduleBox.values.toList();
  }

  // Settings operations
  Future<void> saveSettings(UserSettings settings) async {
    await settingsBox.put('user_settings', settings);
  }

  UserSettings getSettings() {
    return settingsBox.get('user_settings') ?? UserSettings.defaultSettings();
  }
}
