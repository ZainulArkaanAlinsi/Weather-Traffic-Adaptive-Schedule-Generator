import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/schedule.dart';
import '../models/settings.dart';
import '../services/weather_service.dart';
import '../services/traffic_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../ai/schedule_generator.dart';

class AppProvider extends ChangeNotifier {
  final AIScheduleGenerator _aiGenerator = AIScheduleGenerator();
  final DatabaseService _databaseService = DatabaseService();
  final WeatherService _weatherService = WeatherService();
  final TrafficService _trafficService = TrafficService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  String? _error;
  List<Task> _tasks = [];
  List<Schedule> _schedules = [];
  UserSettings? _settings;
  Map<String, dynamic>? _weatherData;
  String? _currentCity;
  String? _aiInsights;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Task> get tasks => _tasks;
  List<Schedule> get schedules => _schedules;
  UserSettings? get settings => _settings;
  Map<String, dynamic>? get weatherData => _weatherData;
  String? get currentCity => _currentCity;
  String? get aiInsights => _aiInsights;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    await _databaseService.init();
    await loadSettings();
    await loadTasks();
    await loadSchedules();
    await fetchWeather();
  }

  Future<void> loadSettings() async {
    try {
      _settings = _databaseService.getSettings();
      _currentCity = _settings?.cityName ?? 'Jakarta';
      notifyListeners();
    } catch (e) {
      _settings = UserSettings.defaultSettings();
      _currentCity = _settings?.cityName ?? 'Jakarta';
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    try {
      _tasks = _databaseService.getAllTasks();
      if (_tasks.isEmpty) {
        _tasks = _getSampleTasks();
        for (final task in _tasks) {
          await _databaseService.addTask(task);
        }
      }
      notifyListeners();
    } catch (e) {
      _tasks = _getSampleTasks();
      notifyListeners();
    }
  }

  List<Task> _getSampleTasks() {
    final now = DateTime.now();
    return [
      Task(
        title: 'Morning Meeting with Team',
        duration: 60,
        priority: Priority.high,
        deadline: now.add(const Duration(days: 1)),
        isOutdoor: false,
        weatherConstraint: WeatherConstraint.noPreference,
        trafficConstraint: TrafficConstraint.noPreference,
        location: 'Office',
        destination: 'Office',
        scheduledTime: DateTime(now.year, now.month, now.day, 9, 0),
        status: TaskStatus.scheduled,
      ),
      Task(
        title: 'Client Presentation',
        duration: 90,
        priority: Priority.high,
        deadline: now.add(const Duration(days: 2)),
        isOutdoor: false,
        weatherConstraint: WeatherConstraint.noPreference,
        trafficConstraint: TrafficConstraint.noPreference,
        scheduledTime: DateTime(now.year, now.month, now.day, 11, 0),
        status: TaskStatus.scheduled,
      ),
      Task(
        title: 'Lunch Break',
        duration: 60,
        priority: Priority.low,
        isOutdoor: false,
        weatherConstraint: WeatherConstraint.noPreference,
        trafficConstraint: TrafficConstraint.noPreference,
        scheduledTime: DateTime(now.year, now.month, now.day, 12, 30),
        status: TaskStatus.scheduled,
      ),
      Task(
        title: 'Outdoor Exercise',
        duration: 45,
        priority: Priority.medium,
        deadline: now.add(const Duration(days: 1)),
        isOutdoor: true,
        weatherConstraint: WeatherConstraint.noRain,
        trafficConstraint: TrafficConstraint.noPreference,
        location: 'City Park',
        destination: 'City Park',
        scheduledTime: DateTime(now.year, now.month, now.day, 17, 0),
        status: TaskStatus.scheduled,
      ),
      Task(
        title: 'Project Review',
        duration: 30,
        priority: Priority.medium,
        isOutdoor: false,
        weatherConstraint: WeatherConstraint.noPreference,
        trafficConstraint: TrafficConstraint.noPreference,
        scheduledTime: DateTime(now.year, now.month, now.day, 14, 0),
        status: TaskStatus.scheduled,
      ),
    ];
  }

  Future<void> loadSchedules() async {
    try {
      _schedules = _databaseService.getAllSchedules();
      notifyListeners();
    } catch (e) {
      _schedules = [];
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _databaseService.addTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _databaseService.updateTask(task);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> saveSettings(UserSettings newSettings) async {
    try {
      await _databaseService.saveSettings(newSettings);
      _settings = newSettings;
      _currentCity = newSettings.cityName;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchWeather() async {
    if (_settings?.cityName == null ||
        _settings?.apiKeyOpenWeather == null ||
        _settings!.apiKeyOpenWeather!.isEmpty) {
      _error = 'Please configure API key in settings';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeatherForecast(
        _settings!.cityName,
        _settings!.apiKeyOpenWeather!,
      );
    } catch (e) {
      _error = 'Failed to fetch weather: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getTrafficInfo(
    String origin,
    String destination,
  ) async {
    if (_settings?.apiKeyGoogleMaps == null ||
        _settings!.apiKeyGoogleMaps!.isEmpty) {
      return null;
    }
    try {
      return await _trafficService.getTrafficInfo(
        origin,
        destination,
        _settings!.apiKeyGoogleMaps!,
      );
    } catch (e) {
      return null;
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.scheduledTime == null) return false;
      return task.scheduledTime!.year == date.year &&
          task.scheduledTime!.month == date.month &&
          task.scheduledTime!.day == date.day;
    }).toList();
  }

  Schedule? getScheduleForDate(DateTime date) {
    try {
      return _schedules.firstWhere((s) {
        return s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day;
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> rescheduleTaskDueToWeather(
    Task task,
    String newTime,
    String reason,
  ) async {
    final updatedTask = task.copyWith(
      scheduledTime: DateTime.parse(newTime),
      status: TaskStatus.rescheduled,
      rescheduleReason: reason,
    );
    await updateTask(updatedTask);
    await _notificationService.showNotification(
      title: 'Task Rescheduled',
      body: '${task.title}: $reason',
    );
  }

  Future<void> checkAndRescheduleTasks() async {
    if (_weatherData == null) {
      await fetchWeather();
    }
  }

  Future<Map<String, dynamic>> generateAISchedule(DateTime date) async {
    if (_settings == null) {
      return {'success': false, 'message': 'Please configure settings first'};
    }

    final pendingTasks = _tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList();
    if (pendingTasks.isEmpty) {
      return {'success': false, 'message': 'No pending tasks to schedule'};
    }

    List<Task> processedTasks = List.from(pendingTasks);

    if (_weatherData != null) {
      processedTasks = _aiGenerator.processWeatherConstraints(
        processedTasks,
        _weatherData!,
      );
    }

    final workloadInfo = _aiGenerator.checkWorkloadBalance(
      processedTasks,
      _settings!,
    );

    final prioritizedTasks = _aiGenerator.prioritizeTasks(processedTasks);
    final scheduledTasks = _aiGenerator.assignTimeSlots(
      prioritizedTasks,
      _settings!,
      date,
    );

    for (final task in scheduledTasks) {
      if (task.status == TaskStatus.scheduled) {
        await updateTask(task);
      }
    }

    // Call Gemini!
    final String insights = await _aiGenerator.generateAIInsights(
      scheduledTasks,
      _settings!,
      _weatherData,
    );
    
    _aiInsights = insights;
    notifyListeners();

    final totalScheduled = scheduledTasks
        .where((t) => t.status == TaskStatus.scheduled)
        .length;
    final totalRescheduled = scheduledTasks
        .where((t) => t.status == TaskStatus.rescheduled)
        .length;

    return {
      'success': true,
      'message':
          '$totalScheduled scheduled, $totalRescheduled rescheduled. AI Insights ter-update!',
      'insights': insights,
      'workload': workloadInfo,
    };
  }

  Map<String, dynamic> checkWorkloadBalance() {
    if (_settings == null) {
      return {
        'isOverloaded': false,
        'overtime': 0,
        'totalAvailable': 0,
        'totalTask': 0,
      };
    }
    final pendingTasks = _tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList();
    return _aiGenerator.checkWorkloadBalance(pendingTasks, _settings!);
  }

  List<Task> getWeeklyTasks(DateTime startOfWeek) {
    return _tasks.where((task) {
      if (task.scheduledTime == null) return false;
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return task.scheduledTime!.isAfter(startOfWeek) &&
          task.scheduledTime!.isBefore(endOfWeek);
    }).toList();
  }
}
