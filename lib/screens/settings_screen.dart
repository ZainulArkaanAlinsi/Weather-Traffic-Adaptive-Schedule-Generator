import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/settings.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _cityController;
  late TextEditingController _homeLocationController;
  late TextEditingController _openWeatherKeyController;
  late TextEditingController _googleMapsKeyController;
  late TextEditingController _geminiKeyController;
  late TextEditingController _breakDurationController;

  String _wakeUpTime = '05:30';
  String _workStartTime = '08:00';
  String _workEndTime = '17:00';
  String _breakStartTime = '12:00';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppProvider>().settings;
    _cityController = TextEditingController(
      text: settings?.cityName ?? 'Jakarta',
    );
    _homeLocationController = TextEditingController(
      text: settings?.homeLocation ?? 'Jakarta',
    );
    _openWeatherKeyController = TextEditingController(
      text: settings?.apiKeyOpenWeather ?? '',
    );
    _googleMapsKeyController = TextEditingController(
      text: settings?.apiKeyGoogleMaps ?? '',
    );
    _geminiKeyController = TextEditingController(
      text: settings?.apiKeyGemini ?? '',
    );
    _breakDurationController = TextEditingController(
      text: (settings?.preferredBreakDuration ?? 60).toString(),
    );

    if (settings != null) {
      _wakeUpTime = settings.wakeUpTime;
      _workStartTime = settings.workStartTime;
      _workEndTime = settings.workEndTime;
      _breakStartTime = settings.preferredBreakStart;
      _notificationsEnabled = settings.isNotificationEnabled;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _homeLocationController.dispose();
    _openWeatherKeyController.dispose();
    _googleMapsKeyController.dispose();
    _geminiKeyController.dispose();
    _breakDurationController.dispose();
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Location Settings'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cityController,
                          label: 'City (for weather)',
                          hint: 'Jakarta',
                          icon: Icons.location_city_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _homeLocationController,
                          label: 'Home Address',
                          hint: 'Jakarta Selatan',
                          icon: Icons.home_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Schedule Settings'),
                        const SizedBox(height: 16),
                        _buildTimeRow(
                          'Wake Up Time',
                          _wakeUpTime,
                          Icons.wb_sunny_rounded,
                          (time) => setState(() => _wakeUpTime = time),
                        ),
                        _buildTimeRow(
                          'Work Start',
                          _workStartTime,
                          Icons.work_rounded,
                          (time) => setState(() => _workStartTime = time),
                        ),
                        _buildTimeRow(
                          'Work End',
                          _workEndTime,
                          Icons.work_off_rounded,
                          (time) => setState(() => _workEndTime = time),
                        ),
                        _buildTimeRow(
                          'Break Start',
                          _breakStartTime,
                          Icons.coffee_rounded,
                          (time) => setState(() => _breakStartTime = time),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('API Keys'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _openWeatherKeyController,
                          label: 'OpenWeatherMap API Key',
                          hint: 'Enter API key',
                          icon: Icons.cloud_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _googleMapsKeyController,
                          label: 'Google Maps API Key',
                          hint: 'Enter API key',
                          icon: Icons.map_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _geminiKeyController,
                          label: 'Gemini AI API Key (Required for AI Scheduler)',
                          hint: 'Enter Gemini API key',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Notifications'),
                        const SizedBox(height: 16),
                        _buildNotificationToggle(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
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

  Widget _buildHeader() {
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
              'Settings',
              style: TextStyle(
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
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSectionIcon(title),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    if (title.contains('Location')) return Icons.location_on_rounded;
    if (title.contains('Schedule')) return Icons.schedule_rounded;
    if (title.contains('API')) return Icons.key_rounded;
    return Icons.notifications_rounded;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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

  Widget _buildTimeRow(
    String title,
    String time,
    IconData icon,
    Function(String) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final parts = time.split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          ),
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
        if (picked != null) {
          onChanged(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _notificationsEnabled
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_rounded,
            color: _notificationsEnabled ? AppColors.success : Colors.white54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  _notificationsEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveSettings() {
    final settings = UserSettings(
      cityName: _cityController.text,
      homeLocation: _homeLocationController.text,
      workStartTime: _workStartTime,
      workEndTime: _workEndTime,
      preferredBreakStart: _breakStartTime,
      preferredBreakDuration: int.tryParse(_breakDurationController.text) ?? 60,
      wakeUpTime: _wakeUpTime,
      apiKeyOpenWeather: _openWeatherKeyController.text.isEmpty
          ? null
          : _openWeatherKeyController.text,
      apiKeyGoogleMaps: _googleMapsKeyController.text.isEmpty
          ? null
          : _googleMapsKeyController.text,
      apiKeyGemini: _geminiKeyController.text.isEmpty
          ? null
          : _geminiKeyController.text,
      isNotificationEnabled: _notificationsEnabled,
    );
    context.read<AppProvider>().saveSettings(settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
}
