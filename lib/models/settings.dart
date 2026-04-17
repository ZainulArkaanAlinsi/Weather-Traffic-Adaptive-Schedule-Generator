import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends Equatable {
  @HiveField(0)
  final String homeLocation;

  @HiveField(1)
  final String workStartTime;

  @HiveField(2)
  final String workEndTime;

  @HiveField(3)
  final String preferredBreakStart;

  @HiveField(4)
  final int preferredBreakDuration;

  @HiveField(5)
  final String wakeUpTime;

  @HiveField(6)
  final String cityName;

  @HiveField(7)
  final String? apiKeyOpenWeather;

  @HiveField(8)
  final String? apiKeyGoogleMaps;

  @HiveField(9)
  final bool isNotificationEnabled;

  @HiveField(10)
  final String? apiKeyGemini;

  const UserSettings({
    required this.homeLocation,
    required this.workStartTime,
    required this.workEndTime,
    required this.preferredBreakStart,
    required this.preferredBreakDuration,
    required this.wakeUpTime,
    required this.cityName,
    this.apiKeyOpenWeather,
    this.apiKeyGoogleMaps,
    this.apiKeyGemini,
    this.isNotificationEnabled = true,
  });

  factory UserSettings.defaultSettings() {
    return const UserSettings(
      homeLocation: 'Jakarta',
      workStartTime: '08:00',
      workEndTime: '17:00',
      preferredBreakStart: '12:00',
      preferredBreakDuration: 60,
      wakeUpTime: '05:30',
      cityName: 'Jakarta',
      apiKeyOpenWeather: 'YOUR_OPENWEATHER_API_KEY_HERE',
      apiKeyGoogleMaps: 'YOUR_GOOGLE_MAPS_API_KEY_HERE',
      apiKeyGemini: 'YOUR_GEMINI_API_KEY_HERE',
      isNotificationEnabled: true,
    );
  }

  UserSettings copyWith({
    String? homeLocation,
    String? workStartTime,
    String? workEndTime,
    String? preferredBreakStart,
    int? preferredBreakDuration,
    String? wakeUpTime,
    String? cityName,
    String? apiKeyOpenWeather,
    String? apiKeyGoogleMaps,
    String? apiKeyGemini,
    bool? isNotificationEnabled,
  }) {
    return UserSettings(
      homeLocation: homeLocation ?? this.homeLocation,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      preferredBreakStart: preferredBreakStart ?? this.preferredBreakStart,
      preferredBreakDuration:
          preferredBreakDuration ?? this.preferredBreakDuration,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      cityName: cityName ?? this.cityName,
      apiKeyOpenWeather: apiKeyOpenWeather ?? this.apiKeyOpenWeather,
      apiKeyGoogleMaps: apiKeyGoogleMaps ?? this.apiKeyGoogleMaps,
      apiKeyGemini: apiKeyGemini ?? this.apiKeyGemini,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'homeLocation': homeLocation,
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
      'preferredBreakStart': preferredBreakStart,
      'preferredBreakDuration': preferredBreakDuration,
      'wakeUpTime': wakeUpTime,
      'cityName': cityName,
      'apiKeyOpenWeather': apiKeyOpenWeather,
      'apiKeyGoogleMaps': apiKeyGoogleMaps,
      'apiKeyGemini': apiKeyGemini,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      homeLocation: map['homeLocation'] ?? 'Jakarta',
      workStartTime: map['workStartTime'] ?? '08:00',
      workEndTime: map['workEndTime'] ?? '17:00',
      preferredBreakStart: map['preferredBreakStart'] ?? '12:00',
      preferredBreakDuration: map['preferredBreakDuration'] ?? 60,
      wakeUpTime: map['wakeUpTime'] ?? '05:30',
      cityName: map['cityName'] ?? 'Jakarta',
      apiKeyOpenWeather: map['apiKeyOpenWeather'],
      apiKeyGoogleMaps: map['apiKeyGoogleMaps'],
      apiKeyGemini: map['apiKeyGemini'],
      isNotificationEnabled: map['isNotificationEnabled'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    homeLocation,
    workStartTime,
    workEndTime,
    preferredBreakStart,
    preferredBreakDuration,
    wakeUpTime,
    cityName,
    apiKeyOpenWeather,
    apiKeyGoogleMaps,
    apiKeyGemini,
    isNotificationEnabled,
  ];
}
