import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'hotels_page.dart';
import 'transportation_page.dart';
import 'special_places_page.dart';
import 'map.dart';

class BeachDetailPage extends StatefulWidget {
  final Map<String, dynamic> beach;

  const BeachDetailPage({Key? key, required this.beach}) : super(key: key);

  @override
  _BeachDetailPageState createState() => _BeachDetailPageState();
}

class _BeachDetailPageState extends State<BeachDetailPage> {
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? hourlyWeatherData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await fetchWeatherData();
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
        throw Exception('Failed to load weather data: ${currentResponse.statusCode}');
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

  Widget _buildWeatherCard() {
    if (currentWeatherData == null) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current Weather",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _getWeatherIcon(currentWeatherData!['weathercode'] as int),
                  size: 32,
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
                          "${currentWeatherData!['temperature']}°C",
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
                          "${currentWeatherData!['windspeed']} km/h",
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
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
                allBeaches: [], // Pass empty list since we're focusing on selected beach
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

// In BeachDetailPage class, replace the _buildBeachImage() method with this:

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
          widget.beach['image'] ?? 'assets/files/placeholder.png', // Use the image path from kochi.dart
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');  // For debugging
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