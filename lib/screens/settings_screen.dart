import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
    _cityController = TextEditingController(text: settings?.cityName ?? 'Jakarta');
    _homeLocationController = TextEditingController(text: settings?.homeLocation ?? 'Jakarta');
    _openWeatherKeyController = TextEditingController(text: settings?.apiKeyOpenWeather ?? '');
    _googleMapsKeyController = TextEditingController(text: settings?.apiKeyGoogleMaps ?? '');
    _geminiKeyController = TextEditingController(text: settings?.apiKeyGemini ?? '');
    _breakDurationController = TextEditingController(text: (settings?.preferredBreakDuration ?? 60).toString());

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: _buildSection('Location', [
                            _buildTextField(_cityController, 'Target City', Icons.location_city_rounded),
                            const SizedBox(height: 16),
                            _buildTextField(_homeLocationController, 'Home Address', Icons.home_rounded),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 500),
                          child: _buildSection('Schedule Preferences', [
                            _buildTimePickerTile('Wake Up', _wakeUpTime, Icons.wb_sunny_rounded, 
                                (t) => setState(() => _wakeUpTime = t)),
                            _buildTimePickerTile('Work Starts', _workStartTime, Icons.work_rounded, 
                                (t) => setState(() => _workStartTime = t)),
                            _buildTimePickerTile('Work Ends', _workEndTime, Icons.work_off_rounded, 
                                (t) => setState(() => _workEndTime = t)),
                            _buildTimePickerTile('Preferred Break', _breakStartTime, Icons.coffee_rounded, 
                                (t) => setState(() => _breakStartTime = t)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 500),
                          child: _buildSection('API Integrations', [
                            _buildTextField(_geminiKeyController, 'Gemini AI Key (Required)', Icons.auto_awesome_rounded, isPassword: true),
                            const SizedBox(height: 16),
                            _buildTextField(_openWeatherKeyController, 'OpenWeather Key', Icons.cloud_rounded, isPassword: true),
                            const SizedBox(height: 16),
                            _buildTextField(_googleMapsKeyController, 'Google Maps Key', Icons.map_rounded, isPassword: true),
                          ]),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 500),
                          child: _buildSection('App Settings', [
                            _buildToggleTile('Push Notifications', _notificationsEnabled, Icons.notifications_active_rounded, 
                                (v) => setState(() => _notificationsEnabled = v)),
                          ]),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: _buildSaveButton(),
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

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
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
          Text('Settings', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
          const SizedBox(width: 48), // Placeholder for balance
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerTile(String title, String time, IconData icon, Function(String) onTap) {
    return InkWell(
      onTap: () async {
        final parts = time.split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
        );
        if (picked != null) {
          onTap('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(time, style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(String title, bool value, IconData icon, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: Text('Save Preferences', style: AppTextStyles.button),
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
      apiKeyOpenWeather: _openWeatherKeyController.text.isEmpty ? null : _openWeatherKeyController.text,
      apiKeyGoogleMaps: _googleMapsKeyController.text.isEmpty ? null : _googleMapsKeyController.text,
      apiKeyGemini: _geminiKeyController.text.isEmpty ? null : _geminiKeyController.text,
      isNotificationEnabled: _notificationsEnabled,
    );
    context.read<AppProvider>().saveSettings(settings);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }
}
