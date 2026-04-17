import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.weatherData == null) {
          return _buildPlaceholderCard();
        }

        final list = provider.weatherData!['list'] as List?;
        if (list == null || list.isEmpty) {
          return _buildPlaceholderCard();
        }

        final current = list.first;
        final main = current['main'] as Map<String, dynamic>?;
        final weather =
            (current['weather'] as List?)?.first as Map<String, dynamic>?;

        if (main == null || weather == null) {
          return _buildPlaceholderCard();
        }

        final temp = (main['temp'] as num?)?.toDouble() ?? 0;
        final humidity = main['humidity'] ?? 0;
        final description = weather['description'] ?? '';
        final iconCode = weather['icon'] ?? '01d';
        final windSpeed = current['wind']?['speed'] ?? 0;

        return FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: _getWeatherGradient(iconCode),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _getWeatherColor(iconCode).withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Icon(
                      _getWeatherIcon(iconCode),
                      size: 140,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider.currentCity ?? 'Jakarta',
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'TODAY, ${_formatCurrentDate()}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flash_on, color: Colors.amber, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${temp.toInt()}',
                                        style: AppTextStyles.heading1.copyWith(
                                          fontSize: 72,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                      Text(
                                        '°',
                                        style: AppTextStyles.heading1.copyWith(
                                          fontSize: 32,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _capitalize(description),
                                    style: AppTextStyles.heading2.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _getWeatherIcon(iconCode),
                              size: 80,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(Icons.water_drop, '$humidity%', 'Humidity'),
                              _buildDetailItem(Icons.air, '${windSpeed.toStringAsFixed(1)}m/s', 'Wind'),
                              _buildDetailItem(Icons.visibility, 'High', 'Visibility'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  LinearGradient _getWeatherGradient(String code) {
    final condition = code.substring(0, 2);
    if (condition == '01' || condition == '02') {
      return const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (condition == '09' || condition == '10' || condition == '11') {
      return const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFF64748B), Color(0xFF334155)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getWeatherColor(String code) {
    final condition = code.substring(0, 2);
    if (condition == '01' || condition == '02') return Colors.orange;
    if (condition == '09' || condition == '10' || condition == '11') return Colors.blue;
    return Colors.blueGrey;
  }

  Widget _buildPlaceholderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }

  IconData _getWeatherIcon(String code) {
    switch (code.substring(0, 2)) {
      case '01': return Icons.wb_sunny_rounded;
      case '02':
      case '03': return Icons.cloud_rounded;
      case '04': return Icons.cloud_rounded;
      case '09':
      case '10': return Icons.grain_rounded;
      case '11': return Icons.thunderstorm_rounded;
      case '13': return Icons.ac_unit_rounded;
      case '50': return Icons.blur_on_rounded;
      default: return Icons.wb_sunny_rounded;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return '${now.day} ${months[now.month - 1]}';
  }
}
