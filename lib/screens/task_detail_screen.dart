import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundElements(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 400),
                          child: _buildMainInfo(),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: _buildDetailsGrid(),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: _buildConstraintSection(),
                        ),
                        if (task.rescheduleReason != null) ...[
                          const SizedBox(height: 32),
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            child: _buildRescheduleInfo(),
                          ),
                        ],
                        const SizedBox(height: 48),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: _buildActionButtons(context),
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          Text('Details', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
          IconButton(
            onPressed: () => _showMoreOptions(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    final priorityColor = _getPriorityColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: priorityColor.withOpacity(0.3)),
          ),
          child: Text(
            task.priority.name.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: priorityColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(task.title, style: AppTextStyles.heading1.copyWith(fontSize: 32)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatusBadge(),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${task.duration} Min', style: AppTextStyles.caption),
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
        icon = Icons.check_circle_rounded;
        break;
      case TaskStatus.scheduled:
        color = AppColors.primary;
        text = 'Scheduled';
        icon = Icons.schedule_rounded;
        break;
      case TaskStatus.rescheduled:
        color = AppColors.warning;
        text = 'Rescheduled';
        icon = Icons.sync_alt_rounded;
        break;
      default:
        color = AppColors.textMuted;
        text = 'Pending';
        icon = Icons.pending_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          if (task.scheduledTime != null)
            _buildDetailTile(Icons.calendar_today_rounded, 'Date & Time', 
                '${task.scheduledTime!.day}/${task.scheduledTime!.month}/${task.scheduledTime!.year} • ${_formatTime(task.scheduledTime!)}'),
          if (task.deadline != null)
            _buildDetailTile(Icons.event_note_rounded, 'Deadline', 
                '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'),
          if (task.location != null)
            _buildDetailTile(Icons.location_on_rounded, 'Location', task.location!),
          if (task.destination != null)
            _buildDetailTile(Icons.directions_rounded, 'Destination', task.destination!),
          _buildDetailTile(Icons.wb_sunny_rounded, 'Activity Environment', 
              task.isOutdoor ? 'Outdoor Activity' : 'Indoor Activity', isLast: true),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Constraints', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildConstraintCard(Icons.cloud_rounded, 'Weather', 
                _getWeatherConstraintText(), _getWeatherConstraintColor()),
            const SizedBox(width: 12),
            _buildConstraintCard(Icons.traffic_rounded, 'Traffic', 
                _getTrafficConstraintText(), _getTrafficConstraintColor()),
          ],
        ),
      ],
    );
  }

  Widget _buildConstraintCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildRescheduleInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reschedule Reason', 
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(task.rescheduleReason!, style: AppTextStyles.body.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _toggleComplete(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.white.withOpacity(0.1) : AppColors.success,
              foregroundColor: isCompleted ? Colors.white : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded),
                const SizedBox(width: 12),
                Text(isCompleted ? 'Mark as Pending' : 'Mark Completed', 
                    style: AppTextStyles.button.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case Priority.high: return AppColors.danger;
      case Priority.medium: return AppColors.warning;
      case Priority.low: return AppColors.success;
    }
  }

  String _getWeatherConstraintText() {
    return task.weatherConstraint.toString().split('.').last;
  }

  Color _getWeatherConstraintColor() {
    if (task.weatherConstraint == WeatherConstraint.noPreference) return AppColors.textSecondary;
    return AppColors.primary;
  }

  String _getTrafficConstraintText() {
    return task.trafficConstraint.toString().split('.').last;
  }

  Color _getTrafficConstraintColor() {
    if (task.trafficConstraint == TrafficConstraint.noPreference) return AppColors.textSecondary;
    return AppColors.accent;
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(Icons.edit_rounded, 'Edit Task', () {
              Navigator.pop(context);
              // TODO: Navigate to edit
            }),
            _buildOptionTile(Icons.delete_outline_rounded, 'Delete Task', () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            }, isDestructive: true),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.danger : Colors.white),
      title: Text(label, style: AppTextStyles.body.copyWith(color: isDestructive ? AppColors.danger : Colors.white)),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteTask(task.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _toggleComplete(BuildContext context) {
    final provider = context.read<AppProvider>();
    final newStatus = task.status == TaskStatus.completed ? TaskStatus.pending : TaskStatus.completed;
    provider.updateTask(task.copyWith(status: newStatus));
    Navigator.pop(context);
  }
}
