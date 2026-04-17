import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task.dart';
import '../models/settings.dart';
import '../services/weather_service.dart';
import '../services/traffic_service.dart';

class AIScheduleGenerator {
  final WeatherService _weatherService = WeatherService();
  final TrafficService _trafficService = TrafficService();

  Future<String> generateAIInsights(List<Task> tasks, UserSettings settings, Map<String, dynamic>? weatherData) async {
    if (settings.apiKeyGemini == null || settings.apiKeyGemini!.isEmpty) {
      return 'API Key Gemini belum disetting di Pengaturan!';
    }
    
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: settings.apiKeyGemini!,
      );

      final taskTitles = tasks.map((t) => '${t.title} (${t.duration} menit, priority: ${t.priority.name})').join(', ');
      final prompt = '''
Anda adalah AI Schedule Assistant. Berikan saya ringkasan singkat dalam Bahasa Indonesia yang profesional dan ramah.
Terdapat ${tasks.length} tugas yang perlu dijadwalkan hari ini: $taskTitles.
Waktu kerja: ${settings.workStartTime} sampai ${settings.workEndTime}.
Cuaca: ${weatherData != null ? 'Datanya tersedia' : 'Tidak ada data'}.
Saran singkat bagaimana saya harus memprioritaskan tugas-tugas ini hari ini? Jangan lebih dari 3 kalimat.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? 'Jadwal berhasil digenerate!';
    } catch (e) {
      return 'Gagal mengambil saran dari Gemini: \${e.toString()}';
    }
  }

  List<Task> processWeatherConstraints(
    List<Task> tasks,
    Map<String, dynamic> weatherData,
  ) {
    final List<Task> processedTasks = [];

    for (final task in tasks) {
      if (!task.isOutdoor) {
        processedTasks.add(task);
        continue;
      }

      final list = weatherData['list'] as List?;
      if (list == null || list.isEmpty) {
        processedTasks.add(task);
        continue;
      }

      final first = list.first;
      final weatherMain =
          (first['weather'] as List?)?.first?['main'] as String? ?? '';
      final temp = (first['main']?['temp'] as num?)?.toDouble() ?? 0;

      Task processedTask = task;
      String? reason;

      if (task.weatherConstraint == WeatherConstraint.noRain &&
          (weatherMain == 'Rain' || weatherMain == 'Drizzle')) {
        reason = 'Hujan, jadwal digeser';
      } else if (task.weatherConstraint == WeatherConstraint.noStorm &&
          weatherMain == 'Thunderstorm') {
        reason = 'Badai, jadwal digeser';
      } else if (task.weatherConstraint == WeatherConstraint.noExtremeHeat &&
          _weatherService.isExtremeHeat(temp)) {
        reason = 'Suhu terlalu panas, jadwal digeser';
      }

      if (reason != null) {
        processedTask = task.copyWith(
          status: TaskStatus.rescheduled,
          rescheduleReason: reason,
        );
      }

      processedTasks.add(processedTask);
    }

    return processedTasks;
  }

  List<Task> processTrafficConstraints(
    List<Task> tasks,
    Map<String, dynamic> trafficData,
    UserSettings settings,
  ) {
    final List<Task> processedTasks = [];

    for (final task in tasks) {
      if (task.location == null ||
          task.destination == null ||
          settings.apiKeyGoogleMaps == null) {
        processedTasks.add(task);
        continue;
      }

      try {
        final rows = trafficData['rows'] as List?;
        if (rows == null || rows.isEmpty) {
          processedTasks.add(task);
          continue;
        }

        final elements = rows.first['elements'] as List?;
        if (elements == null || elements.isEmpty) {
          processedTasks.add(task);
          continue;
        }

        final element = elements.first;
        final normalDuration = element['duration']?['value'] as int? ?? 0;
        final trafficDuration =
            element['duration_in_traffic']?['value'] as int? ?? 0;

        Task processedTask = task;
        String? reason;

        if (_trafficService.isHeavyTraffic(normalDuration, trafficDuration)) {
          if (task.trafficConstraint ==
              TrafficConstraint.rescheduleIfTrafficHeavy) {
            reason = 'Lalu lintas padat, jadwal digeser';
            processedTask = task.copyWith(
              status: TaskStatus.rescheduled,
              rescheduleReason: reason,
            );
          } else if (task.trafficConstraint == TrafficConstraint.switchToZoom) {
            processedTask = task.copyWith(
              title: '${task.title} (via Zoom)',
              rescheduleReason: 'Lalu lintas padat, diganti ke Zoom',
            );
          }
        }

        processedTasks.add(processedTask);
      } catch (e) {
        processedTasks.add(task);
      }
    }

    return processedTasks;
  }

  Map<String, dynamic> checkWorkloadBalance(
    List<Task> tasks,
    UserSettings settings,
  ) {
    final workStart = _parseTimeToDuration(settings.workStartTime);
    final workEnd = _parseTimeToDuration(settings.workEndTime);
    final totalAvailableMinutes =
        workEnd.inMinutes -
        workStart.inMinutes -
        settings.preferredBreakDuration;
    final totalTaskMinutes = tasks.fold<int>(
      0,
      (sum, task) => sum + task.duration,
    );

    final isOverloaded = totalTaskMinutes > totalAvailableMinutes;
    final overtime = isOverloaded
        ? totalTaskMinutes - totalAvailableMinutes
        : 0;

    return {
      'isOverloaded': isOverloaded,
      'overtime': overtime,
      'totalAvailable': totalAvailableMinutes,
      'totalTask': totalTaskMinutes,
    };
  }

  List<Task> prioritizeTasks(List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      final priorityWeight = {
        Priority.high: 3,
        Priority.medium: 2,
        Priority.low: 1,
      };
      final aWeight = priorityWeight[a.priority]!;
      final bWeight = priorityWeight[b.priority]!;

      if (a.deadline != null && b.deadline != null) {
        final deadlineDiff = a.deadline!.compareTo(b.deadline!);
        if (deadlineDiff != 0) return deadlineDiff;
      }

      return bWeight.compareTo(aWeight);
    });
    return sortedTasks;
  }

  List<Task> assignTimeSlots(
    List<Task> tasks,
    UserSettings settings,
    DateTime date,
  ) {
    final workStart = _parseTimeToDuration(settings.workStartTime);
    final workEnd = _parseTimeToDuration(settings.workEndTime);
    final breakStart = _parseTimeToDuration(settings.preferredBreakStart);

    DateTime currentTime = DateTime(
      date.year,
      date.month,
      date.day,
      workStart.inHours,
      workStart.inMinutes % 60,
    );
    final breakEndMinutes =
        breakStart.inMinutes + settings.preferredBreakDuration;
    final workEndMinutes = workEnd.inMinutes;

    final List<Task> scheduledTasks = [];

    for (final task in tasks) {
      if (task.status == TaskStatus.completed ||
          task.status == TaskStatus.rescheduled) {
        scheduledTasks.add(task);
        continue;
      }

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final proposedEndMinutes = currentMinutes + task.duration;

      if (proposedEndMinutes > workEndMinutes) {
        final rescheduledTask = task.copyWith(
          status: TaskStatus.rescheduled,
          rescheduleReason: 'Melewati jam kerja, dijadwalkan besok',
        );
        scheduledTasks.add(rescheduledTask);
        continue;
      }

      final taskOverlapsBreak =
          currentMinutes < breakEndMinutes &&
          proposedEndMinutes > breakStart.inMinutes;
      if (taskOverlapsBreak) {
        currentTime = DateTime(
          date.year,
          date.month,
          date.day,
          breakEndMinutes ~/ 60,
          breakEndMinutes % 60,
        );
      }

      final scheduledTask = task.copyWith(
        scheduledTime: currentTime,
        status: TaskStatus.scheduled,
      );
      scheduledTasks.add(scheduledTask);

      currentTime = DateTime(
        date.year,
        date.month,
        date.day,
        proposedEndMinutes ~/ 60,
        proposedEndMinutes % 60,
      );
      final bufferMinutes = currentTime.hour * 60 + currentTime.minute + 15;
      currentTime = DateTime(
        date.year,
        date.month,
        date.day,
        bufferMinutes ~/ 60,
        bufferMinutes % 60,
      );
    }

    return scheduledTasks;
  }

  Duration _parseTimeToDuration(String timeStr) {
    final parts = timeStr.split(':');
    return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
  }
}
