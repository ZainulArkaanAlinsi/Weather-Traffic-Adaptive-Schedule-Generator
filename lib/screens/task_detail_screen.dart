import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1E3A5F), const Color(0xFF0D253F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        const SizedBox(height: 24),
                        _buildInfoSection(),
                        const SizedBox(height: 24),
                        _buildConstraintSection(),
                        if (task.rescheduleReason != null) ...[
                          const SizedBox(height: 24),
                          _buildRescheduleSection(),
                        ],
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Task Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2D4A6F),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getPriorityColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                task.isOutdoor
                    ? Icons.directions_run_rounded
                    : Icons.work_rounded,
                color: _getPriorityColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;
    switch (task.status) {
      case TaskStatus.completed:
        color = AppColors.success;
        text = 'Completed';
        icon = Icons.check_circle;
        break;
      case TaskStatus.scheduled:
        color = AppColors.primary;
        text = 'Scheduled';
        icon = Icons.schedule;
        break;
      case TaskStatus.rescheduled:
        color = AppColors.warning;
        text = 'Rescheduled';
        icon = Icons.sync_alt;
        break;
      default:
        color = Colors.grey;
        text = 'Pending';
        icon = Icons.pending;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.access_time_rounded,
            'Duration',
            '${task.duration} menit',
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow(Icons.flag_rounded, 'Priority', _getPriorityText()),
          const Divider(color: Colors.white24, height: 24),
          _buildInfoRow(
            Icons.wb_sunny_rounded,
            'Type',
            task.isOutdoor ? 'Outdoor' : 'Indoor',
          ),
          if (task.scheduledTime != null) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow(
              Icons.schedule_rounded,
              'Scheduled',
              _formatDateTime(task.scheduledTime!),
            ),
          ],
          if (task.deadline != null) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow(
              Icons.event_rounded,
              'Deadline',
              _formatDateTime(task.deadline!),
            ),
          ],
          if (task.location != null && task.location!.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow(
              Icons.location_on_rounded,
              'Location',
              task.location!,
            ),
          ],
          if (task.destination != null && task.destination!.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 24),
            _buildInfoRow(
              Icons.directions_rounded,
              'Destination',
              task.destination!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConstraintSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Constraints',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildConstraintRow(
                Icons.cloud_rounded,
                'Weather Constraint',
                _getWeatherConstraintText(),
                _getWeatherConstraintColor(),
              ),
              const SizedBox(height: 12),
              _buildConstraintRow(
                Icons.traffic_rounded,
                'Traffic Constraint',
                _getTrafficConstraintText(),
                _getTrafficConstraintColor(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConstraintRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRescheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reschedule Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.sync_alt_rounded,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.rescheduleReason!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleComplete(context),
            icon: Icon(
              task.status == TaskStatus.completed ? Icons.undo : Icons.check,
            ),
            label: Text(
              task.status == TaskStatus.completed ? 'Undo' : 'Complete',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: task.status == TaskStatus.completed
                  ? Colors.grey
                  : AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
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

  String _getWeatherConstraintText() {
    switch (task.weatherConstraint) {
      case WeatherConstraint.noPreference:
        return 'No Preference';
      case WeatherConstraint.noRain:
        return 'No Rain';
      case WeatherConstraint.noExtremeHeat:
        return 'No Extreme Heat';
      case WeatherConstraint.noStorm:
        return 'No Storm';
    }
  }

  Color _getWeatherConstraintColor() {
    switch (task.weatherConstraint) {
      case WeatherConstraint.noPreference:
        return Colors.grey;
      case WeatherConstraint.noRain:
        return Colors.blue;
      case WeatherConstraint.noExtremeHeat:
        return Colors.orange;
      case WeatherConstraint.noStorm:
        return Colors.purple;
    }
  }

  String _getTrafficConstraintText() {
    switch (task.trafficConstraint) {
      case TrafficConstraint.noPreference:
        return 'No Preference';
      case TrafficConstraint.rescheduleIfTrafficHeavy:
        return 'Reschedule if Heavy';
      case TrafficConstraint.switchToZoom:
        return 'Switch to Zoom';
    }
  }

  Color _getTrafficConstraintColor() {
    switch (task.trafficConstraint) {
      case TrafficConstraint.noPreference:
        return Colors.grey;
      case TrafficConstraint.rescheduleIfTrafficHeavy:
        return Colors.orange;
      case TrafficConstraint.switchToZoom:
        return Colors.green;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D4A6F),
        title: const Text('Delete Task', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteTask(task.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleComplete(BuildContext context) {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    context.read<AppProvider>().updateTask(task.copyWith(status: newStatus));
    Navigator.pop(context);
  }
}
