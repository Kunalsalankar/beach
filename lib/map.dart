import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Example data structure for a beach
class Beach {
  final String name;
  final String location;
  final List<double> coordinates;
  double? temperature;

  Beach({
    required this.name,
    required this.location,
    required this.coordinates,
    this.temperature,
  });
}

class MapPage extends StatefulWidget {
  final Map<String, dynamic> selectedBeach;
  final List<Map<String, dynamic>> allBeaches;

  const MapPage({
    Key? key,
    required this.selectedBeach,
    required this.allBeaches,
  }) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  bool isLoading = true;
  List<Beach> beaches = [];

  @override
  void initState() {
    super.initState();
    beaches = [
      Beach(
        name: widget.selectedBeach['name'],
        location: widget.selectedBeach['location'],
        coordinates: List<double>.from(widget.selectedBeach['coordinates']),
      ),
      ...widget.allBeaches.map((beach) => Beach(
        name: beach['name'],
        location: beach['location'],
        coordinates: List<double>.from(beach['coordinates']),
      )),
    ];
    _fetchTemperatures();
  }

  Future<void> _fetchTemperatures() async {
    setState(() => isLoading = true);

    for (var beach in beaches) {
      try {
        final temperature = await _getTemperature(
          beach.coordinates[0],
          beach.coordinates[1],
        );
        setState(() {
          beach.temperature = temperature;
        });
      } catch (e) {
        debugPrint('Error fetching temperature for ${beach.name}: $e');
      }
    }

    setState(() => isLoading = false);
  }

  Future<double> _getTemperature(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['current_weather']['temperature'].toDouble();
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 24 && temperature <= 35) {
      return Colors.green; // Safe zone
    } else if ((temperature >= 20 && temperature <= 23) ||
        (temperature >= 31 && temperature <= 33)) {
      return Colors.yellow; // Moderately Safe zone
    } else if ((temperature >= 18 && temperature <= 19) ||
        (temperature >= 34 && temperature <= 35)) {
      return Colors.orange; // Cautious zone
    } else {
      return Colors.red; // Unsafe zone
    }
  }

  List<CircleMarker> _buildHeatmapCircles(Beach beach) {
    if (beach.temperature == null) return [];

    final baseColor = _getTemperatureColor(beach.temperature!);
    final location = LatLng(beach.coordinates[0], beach.coordinates[1]);

    // Increased radii values for better visibility
    final List<Map<String, double>> circles = [
      {'radius': 5000, 'opacity': 0.1}, // Larger outer circle
      {'radius': 3500, 'opacity': 0.2},
      {'radius': 2000, 'opacity': 0.3},
      {'radius': 1000, 'opacity': 0.4}, // Smaller inner circle
    ];

    return circles.map((circle) {
      return CircleMarker(
        point: location,
        radius: circle['radius']!,
        useRadiusInMeter: true,
        color: baseColor.withOpacity(circle['opacity']!),
        borderColor: Colors.transparent,
        borderStrokeWidth: 0,
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Positioned(
      right: 16,
      top: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _legendItem(Colors.blue, 'Safe: 24-30°C'),
            _legendItem(Colors.green, 'Moderately Safe: 20-23°C & 31-33°C'),
            _legendItem(Colors.orange, 'Cautious: 18-19°C & 34-35°C'),
            _legendItem(Colors.red, 'Unsafe: <18°C & >35°C'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach Temperature Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTemperatures,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(8.7370, 76.7066), // Centered on Kerala
              initialZoom: 9.5, // Adjusted zoom level for better visibility
              minZoom: 7, // Added minimum zoom constraint
              maxZoom: 18, // Added maximum zoom constraint
              interactionOptions: const InteractionOptions(
                enableMultiFingerGestureRace: true,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                maxZoom: 19,
              ),
              CircleLayer(
                circles:
                beaches.expand((beach) => _buildHeatmapCircles(beach)).toList(),
              ),
              MarkerLayer(
                markers: beaches.map((beach) {
                  return Marker(
                    point: LatLng(beach.coordinates[0], beach.coordinates[1]),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(beach.name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${beach.location}'),
                                if (beach.temperature != null)
                                  Text(
                                    'Temperature: ${beach.temperature!.toStringAsFixed(1)}°C',
                                  ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: beach.temperature != null
                            ? _getTemperatureColor(beach.temperature!)
                            : Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          _buildLegend(),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}