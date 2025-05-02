

import 'dart:convert';
import 'package:agriinsight_ai/constants/weather_api.dart';
import 'package:http/http.dart' as http;


class WeatherData {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });
}


class WeatherService {
  static Future<WeatherData> fetchWeather(double lat, double lon) async {
    final url = WeatherApiConstants.currentWeatherUrl(lat, lon);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return WeatherData(
        temperature: data['main']['temp'].toDouble(),
        description: data['weather'][0]['description'],
        humidity: data['main']['humidity'],
        windSpeed: data['wind']['speed'].toDouble(),
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
