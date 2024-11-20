import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'hotels_page.dart';
import 'transportation_page.dart';
import 'special_places_page.dart';
import 'map.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class BeachDetailPage extends StatefulWidget {
  final Map<String, dynamic> beach;

  const BeachDetailPage({Key? key, required this.beach}) : super(key: key);

  @override
  _BeachDetailPageState createState() => _BeachDetailPageState();
}

class _BeachDetailPageState extends State<BeachDetailPage> {
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? hourlyWeatherData;
  Map<String, dynamic>? openWeatherData;
  List<Map<String, dynamic>>? dailyForecast;  // Add this state variable
  bool isLoading = true;
  String? errorMessage;
  final String openWeatherApiKey = '380f110a19b8728fdc159ab69547cbc0';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        fetchWeatherData(),
        fetchOpenWeatherData(),
      ]);
      _processDailyForecast();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error initializing data: $e");
      if (mounted) {
        setState(() {
          errorMessage = "Unable to load weather data";
          isLoading = false;
        });
      }
    }
  }
  void _processDailyForecast() {
    if (openWeatherData == null || !mounted) return;

    try {
      final List<dynamic> hourlyList = openWeatherData!['list'];
      Map<String, Map<String, dynamic>> dailyMap = {};

      for (var hourlyData in hourlyList) {
        final DateTime date = DateTime.parse(hourlyData['dt_txt']);
        final String dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!dailyMap.containsKey(dateKey)) {
          dailyMap[dateKey] = {
            'date': date,
            'minTemp': double.infinity,
            'maxTemp': double.negativeInfinity,
            'weatherId': hourlyData['weather'][0]['id'],
            'description': hourlyData['weather'][0]['description'],
            'humidity': hourlyData['main']['humidity'],
            'windSpeed': hourlyData['wind']['speed'],
          };
        }

        // Safely convert temperature to double
        final dynamic tempValue = hourlyData['main']['temp'];
        final double temp = tempValue is int ? tempValue.toDouble() : tempValue as double;

        dailyMap[dateKey]!['minTemp'] = math.min(
          dailyMap[dateKey]!['minTemp'] as double,
          temp,
        );
        dailyMap[dateKey]!['maxTemp'] = math.max(
          dailyMap[dateKey]!['maxTemp'] as double,
          temp,
        );
      }

      setState(() {
        dailyForecast = dailyMap.values.toList();
      });
    } catch (e) {
      print("Error processing daily forecast: $e");
    }
  }
  Future<void> fetchWeatherData() async {
    if (!mounted) return;

    try {
      final coordinates = widget.beach['coordinates'] as List;
      final latitude = coordinates[0];
      final longitude = coordinates[1];

      final currentWeatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final hourlyWeatherUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation,windspeed_10m,relative_humidity_2m';

      final currentResponse = await http.get(Uri.parse(currentWeatherUrl));
      final hourlyResponse = await http.get(Uri.parse(hourlyWeatherUrl));

      if (!mounted) return;

      if (currentResponse.statusCode == 200 && hourlyResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final hourlyData = json.decode(hourlyResponse.body);

        if (currentData['current_weather'] == null) {
          throw Exception('Invalid current weather data structure');
        }

        setState(() {
          currentWeatherData = currentData['current_weather'];
          hourlyWeatherData = hourlyData['hourly'];
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading weather data: ${e.toString()}";
          isLoading = false;
        });
      }
      print("Error fetching weather data: $e");
    }
  }

  Map<String, dynamic> getBeachSafetyStatus() {
    if (currentWeatherData == null || openWeatherData == null) {
      return {
        'status': 'Unknown',
        'message': 'Weather data unavailable',
        'color': Colors.grey,
        'icon': Icons.question_mark
      };
    }

    final temperature = currentWeatherData!['temperature'] as double;
    final windSpeed = currentWeatherData!['windspeed'] as double;
    final precipitation = hourlyWeatherData?['precipitation'][0] as double? ?? 0.0;
    final weatherCode = currentWeatherData!['weathercode'] as int;

    final openWeatherMain = openWeatherData!['list'][0]['main'];
    final humidity = openWeatherMain['humidity'] as int;
    final dynamic feelsLikeValue = openWeatherMain['feels_like'];
    final double feelsLike = feelsLikeValue is int ? feelsLikeValue.toDouble() : feelsLikeValue;

    bool isDangerousWeather = weatherCode >= 95;
    bool isHighTemperature = temperature > 35 || feelsLike > 38;
    bool isLowTemperature = temperature < 18;
    bool isHighWind = windSpeed > 30;
    bool isHeavyRain = precipitation > 5;
    bool isHighHumidity = humidity > 85;

    if (isDangerousWeather) {
      return {
        'status': 'Unsafe',
        'message': 'Beach visit not recommended due to thunderstorm conditions',
        'color': Colors.red,
        'icon': Icons.warning
      };
    } else if (isHighTemperature || isHighWind || isHeavyRain || isHighHumidity) {
      return {
        'status': 'Dangerous',
        'message': 'Beach conditions are risky. Exercise extreme caution',
        'color': Colors.red,
        'icon': Icons.warning
      };
    } else if (isLowTemperature || windSpeed > 20 || precipitation > 2.5) {
      return {
        'status': 'Caution',
        'message': 'Beach conditions require caution',
        'color': Colors.orange,
        'icon': Icons.warning_amber
      };
    } else if (windSpeed > 15 || precipitation > 1 || temperature < 22) {
      return {
        'status': 'Moderate',
        'message': 'Beach conditions are moderate',
        'color': Colors.yellow,
        'icon': Icons.info_outline
      };
    } else {
      return {
        'status': 'Safe',
        'message': 'Beach conditions are ideal for visiting',
        'color': Colors.green,
        'icon': Icons.check_circle
      };
    }
  }

  Widget _buildWeatherCard() {
    if (currentWeatherData == null || openWeatherData == null) {
      return const SizedBox.shrink();
    }

    final temperature = currentWeatherData!['temperature'] as double;
    final windSpeed = currentWeatherData!['windspeed'] as double;
    final precipitation = hourlyWeatherData?['precipitation'][0] as double? ?? 0.0;

    final openWeatherMain = openWeatherData!['list'][0]['main'];
    final humidity = openWeatherMain['humidity'] as int;
    final dynamic feelsLikeValue = openWeatherMain['feels_like'];
    final double feelsLike = feelsLikeValue is int ? feelsLikeValue.toDouble() : feelsLikeValue;

    final safetyStatus = getBeachSafetyStatus();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Weather",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getWeatherIcon(currentWeatherData!['weathercode'] as int),
                  size: 20,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thermostat, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${temperature.toStringAsFixed(1)}°C ",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.air, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${windSpeed.toStringAsFixed(1)} km/h",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "${precipitation.toStringAsFixed(1)} mm/hr",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.opacity, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Humidity: $humidity%",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    getWeatherDescription(currentWeatherData!['weathercode'] as int),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: safetyStatus['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: safetyStatus['color'],
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    safetyStatus['icon'],
                    color: safetyStatus['color'],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    safetyStatus['status'],
                    style: TextStyle(
                      color: safetyStatus['color'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    safetyStatus['message'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: safetyStatus['color'],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDailyForecast() {
    if (dailyForecast == null || dailyForecast!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "5-Day Forecast",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing here
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero, // Remove default padding
              itemCount: math.min(5, dailyForecast!.length),
              itemBuilder: (context, index) {
                final forecast = dailyForecast![index];
                final date = forecast['date'] as DateTime;
                final minTemp = forecast['minTemp'] as double;
                final maxTemp = forecast['maxTemp'] as double;
                final weatherId = forecast['weatherId'] as int;
                final humidity = forecast['humidity'] as int;
                final windSpeed = forecast['windSpeed'] as double;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index != math.min(4, dailyForecast!.length - 1) ? 12.0 : 0, // Remove padding for last item
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          index == 0
                              ? 'Today'
                              : DateFormat('EEE, MMM d').format(date),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Icon(
                          _getOpenWeatherIcon(weatherId),
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${maxTemp.round()}°',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${minTemp.round()}°',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.water_drop, size: 16, color: Colors.blue),
                              Text(
                                ' ${humidity}%',
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }  Future<void> fetchOpenWeatherData() async {
    if (!mounted) return;

    try {
      final coordinates = widget.beach['coordinates'] as List;
      final latitude = coordinates[0];
      final longitude = coordinates[1];

      final url =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$openWeatherApiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          openWeatherData = data;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        throw Exception(
            'Failed to load OpenWeather data: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Error loading OpenWeather data: ${e.toString()}";
          isLoading = false;
        });
      }
      print("Error fetching OpenWeather data: $e");
    }
  }


  Widget _buildHourlyForecast() {
    if (openWeatherData == null) {
      return const SizedBox.shrink();
    }

    final hourlyForecasts = openWeatherData!['list'] as List;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hourly Forecast",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: math.min(8, hourlyForecasts.length),
                itemBuilder: (context, index) {
                  final forecast = hourlyForecasts[index];
                  final temp = forecast['main']['temp'] as double;
                  final weather = forecast['weather'][0];
                  final time = DateTime.parse(forecast['dt_txt']);

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Text(
                          '${time.hour}:00',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          _getOpenWeatherIcon(weather['id'] as int),
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${temp.round()}°C',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getOpenWeatherIcon(int id) {
    if (id >= 200 && id < 300) return Icons.flash_on; // Thunderstorm
    if (id >= 300 && id < 400) return Icons.grain; // Drizzle
    if (id >= 500 && id < 600) return Icons.beach_access; // Rain
    if (id >= 600 && id < 700) return Icons.ac_unit; // Snow
    if (id >= 700 && id < 800) return Icons.cloud; // Atmosphere
    if (id == 800) return Icons.wb_sunny; // Clear
    if (id > 800) return Icons.cloud_queue; // Clouds
    return Icons.question_mark;
  }

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud_circle;
      case 45:
      case 48:
        return Icons.cloud;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 61:
      case 63:
      case 65:
        return Icons.beach_access;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.umbrella;
      case 85:
      case 86:
        return Icons.umbrella;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on;
      default:
        return Icons.question_mark;
    }
  }

  Widget _buildActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          "View on Map",
          Icons.map,
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                selectedBeach: widget.beach,
                allBeaches: [],
              ),
            ),
          ),
        ),
        _buildActionButton(
          "View Nearby Hotels",
          Icons.hotel,
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelsPage(beach: widget.beach),
            ),
          ),
        ),
        _buildActionButton(
          "Transportation Options",
          Icons.directions_bus,
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransportationPage(beach: widget.beach),
            ),
          ),
        ),
        _buildActionButton(
          "Special Places Nearby",
          Icons.place,
              () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialPlacesPage(beach: widget.beach),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBeachImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: Image.asset(
          widget.beach['image'] ?? 'assets/files/placeholder.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBeachInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.beach['name'],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.beach['location'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.beach['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          if (widget.beach['facilities'] != null) ...[
            const SizedBox(height: 16),
            const Text(
              "Facilities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.beach['facilities'] as List).map((facility) {
                return Chip(
                  label: Text(facility),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
          if (widget.beach['bestTime'] != null) ...[
            const SizedBox(height: 16),
            const Text(
              "Best Time to Visit",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.beach['bestTime'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBeachContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBeachImage(),
          _buildBeachInfo(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWeatherCard(),
                const SizedBox(height: 16),
                _buildHourlyForecast(),
                const SizedBox(height: 16),
                _buildDailyForecast(), // Add this line
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      )
          : _buildBeachContent(),
    );
  }
}
