import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? editTask;

  const AddTaskScreen({super.key, this.editTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _durationController;
  late TextEditingController _locationController;
  late TextEditingController _destinationController;

  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDeadline;
  TimeOfDay? _scheduledTime;
  bool _isOutdoor = false;
  WeatherConstraint _weatherConstraint = WeatherConstraint.noPreference;
  TrafficConstraint _trafficConstraint = TrafficConstraint.noPreference;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editTask?.title ?? '');
    _durationController = TextEditingController(text: widget.editTask?.duration.toString() ?? '30');
    _locationController = TextEditingController(text: widget.editTask?.location ?? '');
    _destinationController = TextEditingController(text: widget.editTask?.destination ?? '');

    if (widget.editTask != null) {
      _selectedPriority = widget.editTask!.priority;
      _selectedDeadline = widget.editTask!.deadline;
      _isOutdoor = widget.editTask!.isOutdoor;
      _weatherConstraint = widget.editTask!.weatherConstraint;
      _trafficConstraint = widget.editTask!.trafficConstraint;
      _scheduledTime = widget.editTask?.scheduledTime != null
          ? TimeOfDay.fromDateTime(widget.editTask!.scheduledTime!)
          : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Stack(
        children: [
          _buildBackgroundGlow(),
          Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: _buildInputGroup(
                            title: 'What needs to be done?',
                            child: _buildTextField(
                              controller: _titleController,
                              hint: 'Task name...',
                              icon: Icons.edit_note_rounded,
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInputGroup(
                                  title: 'Duration',
                                  child: _buildTextField(
                                    controller: _durationController,
                                    hint: 'Min',
                                    icon: Icons.timer_outlined,
                                    keyboardType: TextInputType.number,
                                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputGroup(
                                  title: 'Priority',
                                  child: _buildPrioritySelector(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: _buildInputGroup(
                            title: 'Schedule & Deadline',
                            child: _buildDateTimeSelectors(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: _buildInputGroup(
                            title: 'Activity Type',
                            child: _buildOutdoorSettings(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: _buildInputGroup(
                            title: 'Location Details',
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _locationController,
                                  hint: 'Current location (optional)',
                                  icon: Icons.my_location_rounded,
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _destinationController,
                                  hint: 'Destination (optional)',
                                  icon: Icons.place_rounded,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: 100,
      left: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [AppColors.primary.withOpacity(0.15), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.editTask != null ? 'Edit Task' : 'New Task',
            style: AppTextStyles.heading2.copyWith(fontSize: 24),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInputGroup({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TextFormField(
        controller: controller,
        style: AppTextStyles.body,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: Priority.values.map((p) {
          final isSelected = _selectedPriority == p;
          final color = p == Priority.high ? AppColors.danger : (p == Priority.medium ? AppColors.warning : AppColors.success);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
                ),
                child: Center(
                  child: Text(
                    p.name[0].toUpperCase() + p.name.substring(1),
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassButton(
            icon: Icons.calendar_today_rounded,
            label: _selectedDeadline != null 
              ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}' 
              : 'Set Date',
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassButton(
            icon: Icons.access_time_rounded,
            label: _scheduledTime != null 
              ? _scheduledTime!.format(context) 
              : 'Set Time',
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildOutdoorSettings() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_rounded, color: _isOutdoor ? Colors.orange : AppColors.textMuted),
                  const SizedBox(width: 12),
                  Text('Outdoor Activity', style: AppTextStyles.body),
                ],
              ),
              Switch(
                value: _isOutdoor,
                onChanged: (v) => setState(() => _isOutdoor = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (_isOutdoor) ...[
          const SizedBox(height: 12),
          _buildConstraintDropdown<WeatherConstraint>(
            items: WeatherConstraint.values,
            value: _weatherConstraint,
            onChanged: (v) => setState(() => _weatherConstraint = v!),
            label: 'Weather Constraint',
          ),
          const SizedBox(height: 12),
          _buildConstraintDropdown<TrafficConstraint>(
            items: TrafficConstraint.values,
            value: _trafficConstraint,
            onChanged: (v) => setState(() => _trafficConstraint = v!),
            label: 'Traffic Constraint',
          ),
        ],
      ],
    );
  }

  Widget _buildConstraintDropdown<T>({
    required List<T> items,
    required T value,
    required ValueChanged<T?> onChanged,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last))).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.background,
        style: AppTextStyles.body,
        hint: Text(label),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background.withOpacity(0), AppColors.background],
          ),
        ),
        child: FadeInUp(
          delay: const Duration(milliseconds: 800),
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.5),
            ),
            child: Text(
              widget.editTask != null ? 'Update Task' : 'Create Task',
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDeadline = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _scheduledTime = time);
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? scheduledDateTime;
    if (_selectedDeadline != null && _scheduledTime != null) {
      scheduledDateTime = DateTime(
        _selectedDeadline!.year,
        _selectedDeadline!.month,
        _selectedDeadline!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    }

    final task = Task(
      id: widget.editTask?.id,
      title: _titleController.text,
      duration: int.parse(_durationController.text),
      priority: _selectedPriority,
      deadline: _selectedDeadline,
      isOutdoor: _isOutdoor,
      weatherConstraint: _weatherConstraint,
      trafficConstraint: _trafficConstraint,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      destination: _destinationController.text.isEmpty ? null : _destinationController.text,
      scheduledTime: scheduledDateTime,
      status: scheduledDateTime != null ? TaskStatus.scheduled : TaskStatus.pending,
    );

    final provider = context.read<AppProvider>();
    if (widget.editTask != null) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }
    Navigator.pop(context);
  }
}
