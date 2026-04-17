import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _titleController = TextEditingController(
      text: widget.editTask?.title ?? '',
    );
    _durationController = TextEditingController(
      text: widget.editTask?.duration.toString() ?? '30',
    );
    _locationController = TextEditingController(
      text: widget.editTask?.location ?? '',
    );
    _destinationController = TextEditingController(
      text: widget.editTask?.destination ?? '',
    );

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
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Basic Information'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _titleController,
                            label: 'Task Title',
                            hint: 'e.g., Morning run at park',
                            icon: Icons.title_rounded,
                            validator: (v) => v?.isEmpty ?? true
                                ? 'Please enter a title'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _durationController,
                            label: 'Duration (minutes)',
                            hint: '30',
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty ?? true
                                ? 'Please enter duration'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Priority & Schedule'),
                          const SizedBox(height: 16),
                          _buildPrioritySelector(),
                          const SizedBox(height: 16),
                          _buildDateTimeSelectors(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Activity Details'),
                          const SizedBox(height: 16),
                          _buildOutdoorToggle(),
                          const SizedBox(height: 16),
                          _buildConstraintSection(),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Location (Optional)'),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            hint: 'e.g., City Park',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _destinationController,
                            label: 'Destination',
                            hint: 'e.g., Office',
                            icon: Icons.directions_outlined,
                          ),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                        ],
                      ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              widget.editTask != null ? 'Edit Task' : 'Add New Task',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Priority',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: Priority.values.map((p) {
              final isSelected = _selectedPriority == p;
              final color = p == Priority.high
                  ? AppColors.danger
                  : p == Priority.medium
                  ? AppColors.warning
                  : AppColors.secondary;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      p.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? color : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(child: _buildDatePicker()),
        const SizedBox(width: 12),
        Expanded(child: _buildTimePicker()),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (c, child) => Theme(
            data: Theme.of(c).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                surface: Color(0xFF1E3A5F),
              ),
            ),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDeadline = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDeadline != null
                  ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                  : 'Deadline',
              style: TextStyle(
                color: _selectedDeadline != null
                    ? Colors.white
                    : Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _scheduledTime ?? TimeOfDay.now(),
          builder: (c, child) => Theme(
            data: Theme.of(c).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                surface: Color(0xFF1E3A5F),
              ),
            ),
            child: child!,
          ),
        );
        if (time != null) setState(() => _scheduledTime = time);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _scheduledTime != null ? _scheduledTime!.format(context) : 'Time',
              style: TextStyle(
                color: _scheduledTime != null ? Colors.white : Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutdoorToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            _isOutdoor ? Icons.wb_sunny_rounded : Icons.home_rounded,
            color: _isOutdoor ? Colors.amber : Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outdoor Activity',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'Task will be affected by weather',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOutdoor,
            onChanged: (v) => setState(() => _isOutdoor = v),
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildConstraintDropdown<WeatherConstraint>(
            label: 'Weather Constraint',
            value: _weatherConstraint,
            items: WeatherConstraint.values,
            getLabel: (w) => w == WeatherConstraint.noPreference
                ? 'No Preference'
                : w == WeatherConstraint.noRain
                ? 'No Rain'
                : w == WeatherConstraint.noExtremeHeat
                ? 'No Extreme Heat'
                : 'No Storm',
            onChanged: (v) =>
                setState(() => _weatherConstraint = v ?? _weatherConstraint),
          ),
          const SizedBox(height: 16),
          _buildConstraintDropdown<TrafficConstraint>(
            label: 'Traffic Constraint',
            value: _trafficConstraint,
            items: TrafficConstraint.values,
            getLabel: (t) => t == TrafficConstraint.noPreference
                ? 'No Preference'
                : t == TrafficConstraint.rescheduleIfTrafficHeavy
                ? 'Reschedule if Heavy'
                : 'Switch to Zoom',
            onChanged: (v) =>
                setState(() => _trafficConstraint = v ?? _trafficConstraint),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF2D4A6F),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: items
                .map(
                  (i) => DropdownMenuItem(value: i, child: Text(getLabel(i))),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Create Task',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
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
      location: _locationController.text.isEmpty
          ? null
          : _locationController.text,
      destination: _destinationController.text.isEmpty
          ? null
          : _destinationController.text,
      scheduledTime: scheduledDateTime,
      status: scheduledDateTime != null
          ? TaskStatus.scheduled
          : TaskStatus.pending,
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
