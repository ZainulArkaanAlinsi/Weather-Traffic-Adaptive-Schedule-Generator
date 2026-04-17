import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getBorderColor(), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPriorityColor().withValues(alpha: 0.4),
                        _getPriorityColor().withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _getPriorityColor().withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(_getIcon(), color: _getPriorityColor(), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.duration} mins',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.flag_rounded,
                            size: 14,
                            color: _getPriorityColor(),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityText(),
                            style: TextStyle(
                              color: _getPriorityColor(),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (task.isOutdoor) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.wb_sunny_outlined,
                              size: 14,
                              color: Colors.amber.withValues(alpha: 0.8),
                            ),
                          ],
                        ],
                      ),
                      if (task.scheduledTime != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: Colors.blueAccent.shade100,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(task.scheduledTime!),
                                style: TextStyle(
                                  color: Colors.blueAccent.shade100,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (task.rescheduleReason != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            )
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  task.rescheduleReason!,
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (task.status) {
      case TaskStatus.completed:
        color = AppColors.success;
        text = 'Done';
        break;
      case TaskStatus.scheduled:
        color = AppColors.primary;
        text = 'Scheduled';
        break;
      case TaskStatus.rescheduled:
        color = AppColors.warning;
        text = 'Rescheduled';
        break;
      default:
        color = Colors.grey;
        text = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (task.rescheduleReason != null) {
      if (task.rescheduleReason!.toLowerCase().contains('hujan') ||
          task.rescheduleReason!.toLowerCase().contains('cuaca')) {
        return AppColors.calendarWeatherReschedule;
      }
      return AppColors.calendarTrafficReschedule;
    }
    return Colors.white.withValues(alpha: 0.1);
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case Priority.high:
        return AppColors.danger;
      case Priority.medium:
        return AppColors.warning;
      case Priority.low:
        return AppColors.secondary;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  IconData _getIcon() {
    if (task.isOutdoor) {
      return Icons.directions_run_rounded;
    }
    return Icons.work_rounded;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
