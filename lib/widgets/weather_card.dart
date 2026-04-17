import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6).withValues(alpha: 0.8),
                const Color(0xFF1D4ED8).withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.currentCity ?? 'Jakarta',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'AI Weather',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                              temp.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                '°C',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _capitalize(description),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildWeatherDetail(Icons.water_drop, '$humidity%'),
                            const SizedBox(width: 16),
                            _buildWeatherDetail(
                              Icons.air,
                              '${windSpeed.toStringAsFixed(1)} m/s',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        _getWeatherIcon(iconCode),
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ],
              ),
              if (list.length > 1) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                const Text(
                  'Next Hours Forecast',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length > 5 ? 5 : list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final itemMain = item['main'] as Map<String, dynamic>?;
                      final itemWeather =
                          (item['weather'] as List?)?.first
                              as Map<String, dynamic>?;
                      final itemTemp =
                          (itemMain?['temp'] as num?)?.toDouble() ?? 0;
                      final itemIcon = itemWeather?['icon'] ?? '01d';
                      final dt = DateTime.fromMillisecondsSinceEpoch(
                        ((item['dt'] as num?) ?? 0).toInt() * 1000,
                      );
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${dt.hour}:00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              _getWeatherIcon(itemIcon),
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${itemTemp.toInt()}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.8),
            const Color(0xFF1D4ED8).withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.wb_sunny_rounded, size: 64, color: Colors.white),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '28°C',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Clear sky',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String code) {
    switch (code.substring(0, 2)) {
      case '01':
        return Icons.wb_sunny_rounded;
      case '02':
      case '03':
        return Icons.cloud_rounded;
      case '04':
        return Icons.cloud_rounded;
      case '09':
      case '10':
        return Icons.grain_rounded;
      case '11':
        return Icons.thunderstorm_rounded;
      case '13':
        return Icons.ac_unit_rounded;
      case '50':
        return Icons.blur_on_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
