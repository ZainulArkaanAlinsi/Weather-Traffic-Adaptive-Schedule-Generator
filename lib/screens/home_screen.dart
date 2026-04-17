import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../widgets/task_card.dart';
import '../widgets/weather_card.dart';
import 'add_task_screen.dart';
import 'settings_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchWeather();
    });
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
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
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildWeatherSection(),
                _buildCalendar(),
                Expanded(child: _buildTaskList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _isGenerating ? null : () => _generateAISchedule(),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.amber,
                      ),
                tooltip: 'Generate AI Schedule',
              ),
              IconButton(
                onPressed: () => _showNotificationPanel(context),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generateAISchedule() async {
    setState(() => _isGenerating = true);
    final provider = context.read<AppProvider>();
    final result = await provider.generateAISchedule(
      _selectedDay ?? DateTime.now(),
    );

    if (mounted) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Schedule generated'),
          backgroundColor: result['success'] == true
              ? AppColors.success
              : AppColors.warning,
        ),
      );
    }
  }

  Widget _buildWeatherSection() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        if (provider.error != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configure API keys in Settings',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const WeatherCard();
      },
    );
  }

  Widget _buildCalendar() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildCalendarHeader(provider),
              const SizedBox(height: 8),
              _calendarFormat == CalendarFormat.week
                  ? _buildWeeklyView(provider)
                  : _buildMonthlyView(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _calendarFormat == CalendarFormat.week
              ? 'Week of ${_getStartOfWeek(_focusedDay).day}/${_getStartOfWeek(_focusedDay).month}'
              : '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            _buildViewToggle(),
            IconButton(
              onPressed: () {
                setState(() {
                  if (_calendarFormat == CalendarFormat.week) {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                    _calendarFormat = CalendarFormat.month;
                  } else {
                    _focusedDay = _focusedDay.add(const Duration(days: 7));
                    _selectedDay = _focusedDay;
                    _calendarFormat = CalendarFormat.week;
                  }
                });
              },
              icon: Icon(
                _calendarFormat == CalendarFormat.week
                    ? Icons.calendar_month_rounded
                    : Icons.view_week_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn('Day', CalendarFormat.week),
          _buildToggleBtn('Month', CalendarFormat.month),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, CalendarFormat format) {
    final isSelected = _calendarFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _calendarFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildMonthlyView(AppProvider provider) {
    return TableCalendar<Task>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _calendarFormat = CalendarFormat.week;
        });
      },
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      eventLoader: (day) => provider.getTasksForDate(day),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: Colors.transparent),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white70, fontSize: 12),
        weekendStyle: TextStyle(color: Colors.white60, fontSize: 12),
      ),
    );
  }

  Widget _buildWeeklyView(AppProvider provider) {
    final startOfWeek = _getStartOfWeek(_focusedDay);
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          final isSelected = isSameDay(_selectedDay, day);
          final isToday = isSameDay(day, DateTime.now());
          final tasks = provider.getTasksForDate(day);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDay = day;
              _focusedDay = day;
            }),
            child: Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isToday
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][day.weekday - 1],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (tasks.isNotEmpty)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final tasks = _selectedDay != null
            ? provider.getTasksForDate(_selectedDay!)
            : <Task>[];

        final workload = provider.checkWorkloadBalance();

        return Column(
          children: [
            if (workload['totalTask'] > 0) _buildWorkloadIndicator(workload),
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskListView(tasks, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorkloadIndicator(Map<String, dynamic> workload) {
    final isOverloaded = workload['isOverloaded'] ?? false;
    final totalTask = workload['totalTask'] ?? 0;
    final totalAvailable = workload['totalAvailable'] ?? 0;
    final overtime = workload['overtime'] ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverloaded
            ? AppColors.warning.withValues(alpha: 0.2)
            : AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverloaded ? AppColors.warning : AppColors.success,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverloaded
                ? Icons.warning_amber_rounded
                : Icons.check_circle_rounded,
            color: isOverloaded ? AppColors.warning : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOverloaded
                  ? 'Workload overloaded by $overtime min'
                  : 'Workload balanced: $totalTask / $totalAvailable min',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for this day',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new task',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListView(List<Task> tasks, AppProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => _showTaskDetail(context, task),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi ☀️';
    if (hour < 17) return 'Selamat siang 🌤️';
    return 'Selamat malam 🌙';
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskScreen(),
    );
  }

  void _showTaskDetail(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
    );
  }

  void _showNotificationPanel(BuildContext context) {
    final insights = context.read<AppProvider>().aiInsights;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Gemini insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (insights == null)
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Belum ada insights dari Gemini hari ini. Silakan generate jadwal terlebih dahulu dengan tombol bintang.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      insights,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
