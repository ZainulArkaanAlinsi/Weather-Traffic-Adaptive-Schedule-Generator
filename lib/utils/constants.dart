import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF10B981);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color calendarNormal = Color(0xFF22C55E);
  static const Color calendarWeatherReschedule = Color(0xFFF59E0B);
  static const Color calendarTrafficReschedule = Color(0xFFEF4444);
  static const Color calendarTrafficPrediction = Color(0xFFF97316);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
