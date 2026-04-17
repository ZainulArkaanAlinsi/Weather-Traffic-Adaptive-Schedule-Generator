import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animate_do/animate_do.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Background Elements
          _buildBackgroundDecorations(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const WeatherCard(),
                        const SizedBox(height: 16),
                        _buildCalendar(),
                        const SizedBox(height: 24),
                        _buildTaskSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: FadeInDown(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: FadeInUp(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInLeft(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Smart Schedule',
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 28,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          FadeInRight(
            child: Row(
              children: [
                _buildHeaderAction(
                  icon: Icons.auto_awesome_rounded,
                  onTap: _isGenerating ? null : () => _generateAISchedule(),
                  color: Colors.amber,
                  isLoading: _isGenerating,
                ),
                const SizedBox(width: 12),
                _buildHeaderAction(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => _showNotificationPanel(context),
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const SettingsScreen())
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
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

  Widget _buildHeaderAction({
    required IconData icon, 
    required VoidCallback? onTap, 
    required Color color,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Center(
          child: isLoading 
            ? const SizedBox(
                width: 20, 
                height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)
              )
            : Icon(icon, color: color, size: 22),
        ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: result['success'] == true
              ? AppColors.success
              : AppColors.warning,
        ),
      );
    }
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TableCalendar<Task>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          titleTextStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          leftChevronIcon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          rightChevronIcon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle),
          defaultTextStyle: AppTextStyles.body,
          weekendTextStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          markerDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTaskSection() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final tasks = _selectedDay != null
            ? provider.getTasksForDate(_selectedDay!)
            : <Task>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasks for today', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                  Text('${tasks.length} total', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 16),
            tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) => TaskCard(
                      task: tasks[index],
                      index: index,
                      onTap: () => _showTaskDetail(context, tasks[index]),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.event_note_rounded, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No tasks yet', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 8),
            Text('Tap + to add your first task', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return ZoomIn(
      child: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primary,
        elevation: 10,
        label: Text('New Task', style: AppTextStyles.button),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING ☀️';
    if (hour < 17) return 'GOOD AFTERNOON 🌤️';
    return 'GOOD EVENING 🌙';
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
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
                ),
                const SizedBox(width: 16),
                Text('Gemini Insights', style: AppTextStyles.heading2),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                insights ?? 'Generating insights...',
                style: AppTextStyles.body.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
