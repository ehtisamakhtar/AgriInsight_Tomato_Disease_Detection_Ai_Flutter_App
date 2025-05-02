import 'package:agriinsight_ai/services/weatherservices.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? weatherData;
  String? city;
  String searchQuery = '';
  bool isLoading = true;
  String error = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      double lat;
      double lon;

      if (searchQuery.trim().isNotEmpty) {
        List<Location> locations = await locationFromAddress(searchQuery);
        lat = locations.first.latitude;
        lon = locations.first.longitude;
        city = searchQuery;
      } else {
        final position = await _determinePosition();
        lat = position.latitude;
        lon = position.longitude;
        final placemarks = await placemarkFromCoordinates(lat, lon);
        city = placemarks.first.locality;
      }

      final data = await WeatherService.fetchWeather(lat, lon);

      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = '⚠️ ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      await Future.delayed(Duration(seconds: 2));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  IconData getWeatherIcon(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('cloud')) return WeatherIcons.cloud;
    if (lower.contains('rain')) return WeatherIcons.rain;
    if (lower.contains('clear')) return WeatherIcons.day_sunny;
    if (lower.contains('storm')) return WeatherIcons.thunderstorm;
    if (lower.contains('snow')) return WeatherIcons.snow;
    return WeatherIcons.day_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadWeather,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchQuery = _searchController.text;
                      });
                      loadWeather();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  loadWeather();
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error.isNotEmpty
                  ? _buildErrorUI()
                  : _buildWeatherInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (city != null)
          Text(city!,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800])),
        const SizedBox(height: 10),
        BoxedIcon(
          getWeatherIcon(weatherData!.description),
          size: 80,
          color: Colors.green[700],
        ),
        const SizedBox(height: 20),
        Text('Temperature', style: TextStyle(fontSize: 20)),
        Text('${weatherData!.temperature.toStringAsFixed(1)}°C',
            style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
        const SizedBox(height: 10),
        Text('Condition: ${weatherData!.description}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text('Humidity: ${weatherData!.humidity}%',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Text('Wind Speed: ${weatherData!.windSpeed} m/s',
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildErrorUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_off, size: 80, color: Colors.red),
        const SizedBox(height: 10),
        const Text("Location services are OFF"),
        TextButton(
          onPressed: () async {
            await Geolocator.openLocationSettings();
          },
          child: const Text("Open Location Settings"),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            loadWeather();
          },
          child: const Text("Retry"),
        ),
      ],
    );
  }
}
