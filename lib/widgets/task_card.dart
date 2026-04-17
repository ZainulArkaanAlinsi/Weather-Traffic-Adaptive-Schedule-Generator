import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/task.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: index * 100),
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  _buildPriorityIcon(),
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
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                            _buildTag(
                              Icons.access_time_rounded,
                              '${task.duration}m',
                              AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            _buildTag(
                              Icons.flag_rounded,
                              _getPriorityText(),
                              _getPriorityColor(),
                            ),
                            if (task.isOutdoor) ...[
                              const SizedBox(width: 12),
                              _buildTag(
                                Icons.wb_sunny_outlined,
                                'Outdoor',
                                Colors.amber,
                              ),
                            ],
                          ],
                        ),
                        if (task.scheduledTime != null) ...[
                          const SizedBox(height: 12),
                          _buildScheduledTimeSection(),
                        ],
                        if (task.rescheduleReason != null) ...[
                          const SizedBox(height: 12),
                          _buildReasonSection(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon() {
    final color = _getPriorityColor();
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Icon(_getIcon(), color: color, size: 26),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
        color = AppColors.textMuted;
        text = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildScheduledTimeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(task.scheduledTime!),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.rescheduleReason!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.danger,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
    return AppColors.glassBorder;
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
