import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

// Data Models
class HeatmapSettings {
  List<HeatmapLayer> layers;
  double maxRadius;
  double minOpacity;
  double maxOpacity;

  HeatmapSettings({
    required this.layers,
    this.maxRadius = 5000,
    this.minOpacity = 0.1,
    this.maxOpacity = 0.4,
  });

  factory HeatmapSettings.defaultSettings() {
    return HeatmapSettings(
      layers: List.generate(4, (index) {
        final progress = (index + 1) / 4;
        return HeatmapLayer(
          radius: 5000 * (1 - progress + 0.2),
          opacity: 0.1 + (0.3 * progress),
        );
      }),
    );
  }
}

class HeatmapLayer {
  double radius;
  double opacity;

  HeatmapLayer({
    required this.radius,
    required this.opacity,
  });
}

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

class PointOfInterest {
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String description;
  final double? rating;
  final double distance;
  final Map<String, dynamic>? additionalInfo;

  PointOfInterest({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.rating,
    required this.distance,
    this.additionalInfo,
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
  List<PointOfInterest> pointsOfInterest = [];
  Set<String> selectedFilters = {'beach', 'restaurant', 'hotel', 'tourist_place'};
  HeatmapSettings heatmapSettings = HeatmapSettings.defaultSettings();
  bool showHeatmapSettings = false;

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
    _fetchNearbyPOIs();
  }

  // Heatmap building function
  List<CircleMarker> _buildHeatmapCircles(Beach beach) {
    if (beach.temperature == null) return [];

    final baseColor = _getTemperatureColor(beach.temperature!);
    final location = LatLng(beach.coordinates[0], beach.coordinates[1]);

    return heatmapSettings.layers.map((layer) {
      return CircleMarker(
        point: location,
        radius: layer.radius,
        useRadiusInMeter: true,
        color: baseColor.withOpacity(layer.opacity),
        borderColor: Colors.transparent,
        borderStrokeWidth: 0,
      );
    }).toList();
  }

  // Heatmap settings dialog
  void _showHeatmapSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Heatmap Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Maximum Radius (meters):'),
                Slider(
                  value: heatmapSettings.maxRadius,
                  min: 1000,
                  max: 10000,
                  divisions: 90,
                  label: '${heatmapSettings.maxRadius.round()}m',
                  onChanged: (value) {
                    setState(() {
                      heatmapSettings.maxRadius = value;
                      _updateHeatmapLayers();
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Opacity Range:'),
                RangeSlider(
                  values: RangeValues(
                    heatmapSettings.minOpacity,
                    heatmapSettings.maxOpacity,
                  ),
                  min: 0.1,
                  max: 1.0,
                  divisions: 90,
                  labels: RangeLabels(
                    heatmapSettings.minOpacity.toStringAsFixed(2),
                    heatmapSettings.maxOpacity.toStringAsFixed(2),
                  ),
                  onChanged: (values) {
                    setState(() {
                      heatmapSettings.minOpacity = values.start;
                      heatmapSettings.maxOpacity = values.end;
                      _updateHeatmapLayers();
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Number of Layers:'),
                DropdownButton<int>(
                  value: heatmapSettings.layers.length,
                  items: List.generate(8, (index) => index + 2)
                      .map((count) => DropdownMenuItem(
                    value: count,
                    child: Text('$count layers'),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _updateLayerCount(value);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  heatmapSettings = HeatmapSettings.defaultSettings();
                });
              },
              child: const Text('Reset to Default'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Trigger a rebuild of the map
      this.setState(() {});
    });
  }

  void _updateHeatmapLayers() {
    final layerCount = heatmapSettings.layers.length;
    heatmapSettings.layers = List.generate(layerCount, (index) {
      final progress = (index + 1) / layerCount;
      return HeatmapLayer(
        radius: heatmapSettings.maxRadius * (1 - progress + 0.2),
        opacity: heatmapSettings.minOpacity +
            ((heatmapSettings.maxOpacity - heatmapSettings.minOpacity) *
                progress),
      );
    });
  }

  void _updateLayerCount(int count) {
    heatmapSettings.layers = List.generate(count, (index) {
      final progress = (index + 1) / count;
      return HeatmapLayer(
        radius: heatmapSettings.maxRadius * (1 - progress + 0.2),
        opacity: heatmapSettings.minOpacity +
            ((heatmapSettings.maxOpacity - heatmapSettings.minOpacity) *
                progress),
      );
    });
  }

  // Rest of the existing methods remain the same...
  // (Include all other methods from the original code)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach & Nearby Places'),
        backgroundColor: Colors.blue, // Basic blue color
        // Or you can use a more specific shade:
        // backgroundColor: Colors.blue[600], // Darker blue
        // backgroundColor: const Color(0xFF2196F3), // Material blue
        // Or use your theme's primary color:
        // backgroundColor: Theme.of(context).primaryColor,
      actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showHeatmapSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchTemperatures();
              _fetchNearbyPOIs();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      widget.selectedBeach['coordinates'][0],
                      widget.selectedBeach['coordinates'][1],
                    ),
                    initialZoom: 12,
                    minZoom: 7,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(
                      enableMultiFingerGestureRace: true,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                      maxZoom: 19,
                    ),
                    CircleLayer<Object>(
                      circles: selectedFilters.contains('beach')
                          ? beaches.expand((beach) => _buildHeatmapCircles(beach)).toList()
                          : [],
                    ),
                    MarkerLayer(
                      markers: [
                        if (selectedFilters.contains('beach'))
                          ...beaches.map((beach) => _buildBeachMarker(beach)),
                        ...pointsOfInterest
                            .where((poi) => selectedFilters.contains(poi.type))
                            .map((poi) => _buildPoiMarker(poi)),
                      ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNearbyPlacesBottomSheet(),
        label: const Text('Show Nearby Places'),
        icon: const Icon(Icons.list),
      ),
    );
  }

  // Helper methods for building markers
  Marker _buildBeachMarker(Beach beach) {
    return Marker(
      point: LatLng(beach.coordinates[0], beach.coordinates[1]),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showBeachDetails(beach),
        child: Icon(
          Icons.beach_access,
          color: beach.temperature != null
              ? _getTemperatureColor(beach.temperature!)
              : Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  Marker _buildPoiMarker(PointOfInterest poi) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 30,
      height: 30,
      child: GestureDetector(
        onTap: () => _showPoiDetails(poi),
        child: Container(
          decoration: BoxDecoration(
            color: _getPoiColor(poi.type).withOpacity(0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            _getPoiIcon(poi.type),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showBeachDetails(Beach beach) {
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
  }

  void _showNearbyPlacesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Places',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _fetchNearbyPOIs();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pointsOfInterest.length,
                itemBuilder: (context, index) {
                  final poi = pointsOfInterest[index];
                  if (!selectedFilters.contains(poi.type)) {
                    return Container();
                  }
                  return _buildPoiListItem(poi, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoiListItem(PointOfInterest poi, BuildContext context) {
    return Card(
        child: ListTile(
        leading: Icon(
        _getPoiIcon(poi.type),
    color: _getPoiColor(poi.type),
    ),
    title: Text(poi.name),
    subtitle: Text(
    '${poi.distance.toStringAsFixed(1)} km away${poi.rating != null ? ' • ${poi.rating!.toStringAsFixed(1)} ⭐' : ''}',
    ),
    onTap: () {
    Navigator.pop(context);
    _mapController.move(
    LatLng(poi.latitude, poi.longitude),
      15,
    );
    _showPoiDetails(poi);
    },
        ),
    );
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  Future<void> _fetchNearbyPOIs() async {
    setState(() => isLoading = true);
    pointsOfInterest.clear();

    for (var beach in beaches) {
      await _fetchPOIsForBeach(beach);
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchPOIsForBeach(Beach beach) async {
    final types = {
      'restaurant': '[amenity=restaurant]',
      'hotel': '[tourism=hotel]',
      'tourist_place': '[tourism~"museum|attraction|viewpoint|artwork|gallery"]',
    };

    for (var entry in types.entries) {
      try {
        final query = '''
        [out:json][timeout:25];
        (
          node${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
          way${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
          relation${entry.value}(around:10000, ${beach.coordinates[0]}, ${beach.coordinates[1]});
        );
        out body;
        >;
        out skel qt;
        ''';

        final response = await http.post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          body: query,
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final elements = data['elements'] as List;

          for (var element in elements) {
            if (element['type'] == 'node' || element['type'] == 'way') {
              final tags = element['tags'] ?? {};
              final lat = element['lat'] ?? element['center']['lat'];
              final lon = element['lon'] ?? element['center']['lon'];

              final distance = _calculateDistance(
                beach.coordinates[0],
                beach.coordinates[1],
                lat.toDouble(),
                lon.toDouble(),
              );

              if (distance <= 10) {
                // Only include POIs within 10km
                pointsOfInterest.add(
                  PointOfInterest(
                    name: tags['name'] ?? 'Unnamed ${entry.key}',
                    type: entry.key,
                    latitude: lat.toDouble(),
                    longitude: lon.toDouble(),
                    description: _generateDescription(tags),
                    rating: tags['rating']?.toDouble(),
                    distance: distance,
                    additionalInfo: tags,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching ${entry.key}s: $e');
      }
    }
  }

  String _generateDescription(Map<String, dynamic> tags) {
    List<String> details = [];

    if (tags['cuisine'] != null) {
      details.add('Cuisine: ${tags['cuisine']}');
    }
    if (tags['opening_hours'] != null) {
      details.add('Hours: ${tags['opening_hours']}');
    }
    if (tags['phone'] != null) {
      details.add('Phone: ${tags['phone']}');
    }
    if (tags['website'] != null) {
      details.add('Website: ${tags['website']}');
    }

    return details.isEmpty ? 'No additional information available' : details.join('\n');
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
    if (temperature >= 24 && temperature <= 30) {
      return Colors.green;
    } else if ((temperature >= 20 && temperature <= 23) ||
        (temperature >= 31 && temperature <= 33)) {
      return Colors.yellow;
    } else if ((temperature >= 18 && temperature <= 19) ||
        (temperature >= 34 && temperature <= 35)) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getPoiIcon(String type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'tourist_place':
        return Icons.photo_camera;
      default:
        return Icons.place;
    }
  }

  Color _getPoiColor(String type) {
    switch (type) {
      case 'restaurant':
        return Colors.orange;
      case 'hotel':
        return Colors.blue;
      case 'tourist_place':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('Beaches'),
            selected: selectedFilters.contains('beach'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('beach');
                } else {
                  selectedFilters.remove('beach');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Restaurants'),
            selected: selectedFilters.contains('restaurant'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('restaurant');
                } else {
                  selectedFilters.remove('restaurant');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Hotels'),
            selected: selectedFilters.contains('hotel'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('hotel');
                } else {
                  selectedFilters.remove('hotel');
                }
              });
            },
          ),
          FilterChip(
            label: const Text('Tourist Places'),
            selected: selectedFilters.contains('tourist_place'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('tourist_place');
                } else {
                  selectedFilters.remove('tourist_place');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      right: 16,
      top: 80,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ],
              ),
              _legendItem(Colors.green, 'Safe: 24-30°C'),
              _legendItem(Colors.yellow, 'Moderate: 20-23°C & 31-33°C'),
              _legendItem(Colors.orange, 'Cautious: 18-19°C & 34-35°C'),
              _legendItem(Colors.red, 'Unsafe: <18°C & >35°C'),
              const Divider(),
              _legendItem(Colors.orange, 'Restaurants'),
              _legendItem(Colors.blue, 'Hotels'),
              _legendItem(Colors.purple, 'Tourist Places'),
            ],
          ),
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showPoiDetails(PointOfInterest poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getPoiIcon(poi.type), color: _getPoiColor(poi.type)),
            const SizedBox(width: 8),
            Expanded(child: Text(poi.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(poi.description),
              const SizedBox(height: 8),
              if (poi.rating != null)
                Text('Rating: ${poi.rating!.toStringAsFixed(1)} ⭐'),
              Text('Distance: ${poi.distance.toStringAsFixed(1)} km'),
              if (poi.additionalInfo != null) ...[
                const Divider(),
                const Text('Additional Information:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...poi.additionalInfo!.entries
                    .where((entry) => entry.key != 'name')
                    .map((entry) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}