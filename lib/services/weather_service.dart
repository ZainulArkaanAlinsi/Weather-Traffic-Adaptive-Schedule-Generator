import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  bool _isDummyKey(String apiKey) {
    return apiKey.isEmpty ||
        apiKey.contains('YOUR_') ||
        apiKey == 'dummy' ||
        apiKey == 'test';
  }

  Map<String, dynamic> _getDummyWeatherData(String city) {
    return {
      'city': {'name': city, 'country': 'ID'},
      'list': [
        {
          'dt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'main': {'temp': 28, 'humidity': 75, 'pressure': 1013},
          'weather': [
            {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
          ],
          'wind': {'speed': 3.5},
        },
        {
          'dt':
              DateTime.now()
                  .add(const Duration(hours: 3))
                  .millisecondsSinceEpoch ~/
              1000,
          'main': {'temp': 30, 'humidity': 70, 'pressure': 1012},
          'weather': [
            {'main': 'Clouds', 'description': 'few clouds', 'icon': '02d'},
          ],
          'wind': {'speed': 2.5},
        },
        {
          'dt':
              DateTime.now()
                  .add(const Duration(hours: 6))
                  .millisecondsSinceEpoch ~/
              1000,
          'main': {'temp': 29, 'humidity': 72, 'pressure': 1011},
          'weather': [
            {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
          ],
          'wind': {'speed': 2.0},
        },
        {
          'dt':
              DateTime.now()
                  .add(const Duration(hours: 9))
                  .millisecondsSinceEpoch ~/
              1000,
          'main': {'temp': 27, 'humidity': 78, 'pressure': 1010},
          'weather': [
            {'main': 'Rain', 'description': 'light rain', 'icon': '10d'},
          ],
          'wind': {'speed': 4.0},
        },
        {
          'dt':
              DateTime.now()
                  .add(const Duration(hours: 12))
                  .millisecondsSinceEpoch ~/
              1000,
          'main': {'temp': 26, 'humidity': 80, 'pressure': 1010},
          'weather': [
            {'main': 'Clouds', 'description': 'overcast clouds', 'icon': '04d'},
          ],
          'wind': {'speed': 3.0},
        },
      ],
    };
  }

  Future<Map<String, dynamic>> getWeatherForecast(
    String city,
    String apiKey,
  ) async {
    if (_isDummyKey(apiKey)) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getDummyWeatherData(city);
    }
    try {
      final response = await _dio.get(
        '$baseUrl/forecast',
        queryParameters: {'q': city, 'appid': apiKey, 'units': 'metric'},
      );
      return response.data;
    } catch (e) {
      return _getDummyWeatherData(city);
    }
  }

  Future<Map<String, dynamic>> getForecast(String city, String apiKey) async {
    return getWeatherForecast(city, apiKey);
  }

  String getWeatherCondition(String main) {
    switch (main.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return 'Rain';
      case 'thunderstorm':
        return 'Storm';
      case 'clear':
        return 'Clear';
      case 'clouds':
        return 'Clouds';
      default:
        return 'Clear';
    }
  }

  bool isExtremeHeat(double temp) {
    return temp > 35;
  }
}
