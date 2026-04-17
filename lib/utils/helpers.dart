import 'package:intl/intl.dart';
import '../models/task.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatTimeFromString(String timeStr) {
    final parts = timeStr.split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static String getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Tinggi';
      case Priority.medium:
        return 'Sedang';
      case Priority.low:
        return 'Rendah';
    }
  }

  static String getWeatherConstraintText(WeatherConstraint constraint) {
    switch (constraint) {
      case WeatherConstraint.noPreference:
        return 'Tidak peduli';
      case WeatherConstraint.noRain:
        return 'Tidak boleh hujan';
      case WeatherConstraint.noExtremeHeat:
        return 'Tidak boleh panas ekstrem';
      case WeatherConstraint.noStorm:
        return 'Tidak boleh badai';
    }
  }

  static String getTrafficConstraintText(TrafficConstraint constraint) {
    switch (constraint) {
      case TrafficConstraint.noPreference:
        return 'Tidak peduli';
      case TrafficConstraint.rescheduleIfTrafficHeavy:
        return 'Jadwal ulang jika macet';
      case TrafficConstraint.switchToZoom:
        return 'Ganti ke Zoom';
    }
  }

  static String getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.scheduled:
        return 'Terjadwal';
      case TaskStatus.rescheduled:
        return 'Direschedule';
      case TaskStatus.completed:
        return 'Selesai';
    }
  }
}
