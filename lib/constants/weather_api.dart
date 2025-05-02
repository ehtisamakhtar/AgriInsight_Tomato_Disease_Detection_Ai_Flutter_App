

class WeatherApiConstants {
  static const String apiKey = '720e4d3ddcc901b56bfb36fa2a1d8272'; // ⬅️ Replace with your actual OpenWeatherMap API key

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String units = 'metric'; // Celsius

  static String currentWeatherUrl(double lat, double lon) {
    return '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=$units';
  }
}
