import 'package:dio/dio.dart';

class TrafficService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://maps.googleapis.com/maps/api/distancematrix';

  bool _isDummyKey(String apiKey) {
    return apiKey.isEmpty ||
        apiKey.contains('YOUR_') ||
        apiKey == 'dummy' ||
        apiKey == 'test';
  }

  Map<String, dynamic> _getDummyTrafficData() {
    final random = DateTime.now().millisecond % 3;
    final scenarios = [
      {'normal': 1800, 'traffic': 2100, 'status': 'Light'},
      {'normal': 1800, 'traffic': 3600, 'status': 'Heavy'},
      {'normal': 1800, 'traffic': 2700, 'status': 'Moderate'},
    ];
    final data = scenarios[random];
    return {
      'rows': [
        {
          'elements': [
            {
              'status': 'OK',
              'distance': {'text': '5.2 km', 'value': 5200},
              'duration': {'text': '30 min', 'value': data['normal'] as int},
              'duration_in_traffic': {
                'text': '35 min',
                'value': data['traffic'] as int,
              },
            },
          ],
        },
      ],
      'trafficStatus': data['status'],
    };
  }

  Future<Map<String, dynamic>> getTrafficInfo(
    String origin,
    String destination,
    String apiKey,
  ) async {
    if (_isDummyKey(apiKey)) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getDummyTrafficData();
    }
    return getTravelTime(origin, destination, apiKey);
  }

  Future<Map<String, dynamic>> getTravelTime(
    String origin,
    String destination,
    String apiKey,
  ) async {
    if (_isDummyKey(apiKey)) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getDummyTrafficData();
    }
    try {
      final response = await _dio.get(
        '$baseUrl/json',
        queryParameters: {
          'origins': origin,
          'destinations': destination,
          'departure_time': 'now',
          'key': apiKey,
        },
      );
      return response.data;
    } catch (e) {
      return _getDummyTrafficData();
    }
  }

  bool isHeavyTraffic(int normalDuration, int trafficDuration) {
    return trafficDuration > normalDuration * 1.5;
  }

  int getExtraMinutes(int normalDuration, int trafficDuration) {
    return (trafficDuration - normalDuration) ~/ 60;
  }
}
