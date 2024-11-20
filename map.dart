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
  bool isSelected;
  Beach({
    required this.name,
    required this.location,
    required this.coordinates,
    this.temperature,
    this.isSelected = false,
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
  final double kochilat = 9.9373;
  final double kochilong = 76.2619;
  final MapController _mapController = MapController();
  bool isLoading = true;
  double? kochiTemperature;
  Beach? selectedLocation; // Track which location is selected for heatmap

  // Declare the missing variables
  List<Beach> beaches = [];
  Beach? selectedBeach;
  bool showHeatmapSettings = false;

  HeatmapSettings heatmapSettings = HeatmapSettings.defaultSettings();

  Set<String> selectedFilters = {
    'beach',
    'restaurant',
    'hotel',
    'tourist_place'
  };
  List<PointOfInterest> pointsOfInterest = [];

  void _showCoordinatesDialog(Beach beach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${beach.name} Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: ${beach.coordinates[0]}'),
            Text('Longitude: ${beach.coordinates[1]}'),
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

  @override
  void initState() {
    super.initState();
    beaches = widget.allBeaches.map((beachData) {
      return Beach(
        name: beachData['name'],
        location: beachData['location'],
        coordinates: List<double>.from(beachData['coordinates']),

      );
    }).toList();

    // Initialize beaches with your coordinates
    beaches = [
      Beach(
        name: 'Fort Kochi Beach',
        location: 'Fort Kochi',
        coordinates: [9.9673, 76.2367],
      ),
      Beach(
        name: 'Cherai Beach',
        location: 'Cherai',
        coordinates: [10.1373, 76.1794],
      ),
      Beach(
        name: 'Kuzhupilly Beach',
        location: 'Kuzhupilly',
        coordinates: [10.1089, 76.1866],
      ),
      Beach(
        name: 'Andhakaranazhi Beach',
        location: 'Andhakaranazhi',
        coordinates: [9.8683, 76.2853],
      ),
      Beach(
        name: 'Rushikonda Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.7569, 83.3784],
      ),
      Beach(
        name: 'Bheemili Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.8903, 83.4521],
      ),
      Beach(
        name: 'Lawson\'s Bay Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.7289, 83.3431],
      ),
      Beach(
        name: 'Sagar Nagar Beach',
        location: 'Visakhapatnam, Andhra Pradesh',
        coordinates: [17.7622, 83.3721],
      ),
      Beach(
        name: 'Andhakaranazhi Beach',
        location: 'Andhakaranazhi',
        coordinates: [9.8683, 76.2853],
      ),
      Beach(
        name: 'Kihim Beach',
        location: 'Alibag, Maharashtra',
        coordinates: [18.7459, 72.8776],
      ),
      Beach(
        name: 'Nagaon Beach',
        location: 'Alibag, Maharashtra',
        coordinates: [18.5920, 72.9107],
      ),
      Beach(
        name: 'Mandwa Beach',
        location: 'Alibag, Maharashtra',
        coordinates: [18.8110, 72.8775],
      ),
      Beach(
        name: 'Akshi Beach',
        location: 'Alibag, Maharashtra',
        coordinates: [18.6284, 72.9102],
      ),
      Beach(
        name: 'Chapora Beach',
        location: 'Anjuna, Goa',
        coordinates: [15.6011, 73.7364],
      ),
      Beach(
        name: 'Ozran Beach',
        location: 'Anjuna, Goa',
        coordinates: [15.5929, 73.7434],
      ),
      Beach(
        name: 'Ashwem Beach',
        location: 'Anjuna, Goa',
        coordinates: [15.6583, 73.7317],
      ),
      Beach(
        name: 'Betalbatim Beach',
        location: 'Anjuna, Goa',
        coordinates: [15.2861, 73.9240],
      ),
      Beach(
        name: 'Sinquerim Beach',
        location: 'Calangute, Goa',
        coordinates: [15.5110, 73.7681],
      ),
      Beach(
        name: 'Vagator Beach',
        location: 'Calangute, Goa',
        coordinates: [15.6031, 73.7433],
      ),
      Beach(
        name: 'Candolim Beach',
        location: 'Calangute, Goa',
        coordinates: [15.5162, 73.7622],
      ),
      Beach(
        name: 'Kappil Beach',
        location: 'Varsoli, Kerala',
        coordinates: [11.7416, 75.4898],
      ),
      Beach(
        name: 'Odayam Beach',
        location: 'Varsoli, Kerala',
        coordinates: [11.7281, 75.4812],
      ),
      Beach(
        name: 'Puthenthope Beach',
        location: 'Varsoli, Kerala',
        coordinates: [8.5241, 76.8834],
      ),
      Beach(
        name: 'Anjengo Beach',
        location: 'Varsoli, Kerala',
        coordinates: [8.6848, 76.7478],
      ),
      Beach(
        name: 'Lighthouse Beach',
        location: 'Kovalam, Kerala',
        coordinates: [8.3836, 76.9467],
      ),
      Beach(
        name: 'Hawa Beach',
        location: 'Kovalam, Kerala',
        coordinates: [8.3851, 76.9471],
      ),
      Beach(
        name: 'Samudra Beach',
        location: 'Kovalam, Kerala',
        coordinates: [8.3912, 76.9505],
      ),
    ];
    selectedLocation = beaches.firstWhere(
          (beach) => beach.name == widget.selectedBeach['name'],
      orElse: () => beaches.first,
    );

    // Mark the selected beach
    if (selectedLocation != null) {
      selectedLocation!.isSelected = true;
      selectedBeach = selectedLocation; // Set selectedBeach explicitly
    }


    _fetchTemperatures();
    _fetchKochiTemperature();
  }

  Future<void> _fetchKochiTemperature() async {
    try {
      final temperature = await _getTemperature(kochilat, kochilong);
      setState(() {
        kochiTemperature = temperature;
      });
    } catch (e) {
      debugPrint('Error fetching temperature for Kochi: $e');
    }
  }

  Color _getKochiMarkerColor() {
    if (kochiTemperature == null) {
      return Colors.teal.withOpacity(0.6);
    }
    return _getTemperatureColor(kochiTemperature!);
  }

  Marker _buildBeachMarker(Beach beach) {
    return Marker(
      point: LatLng(beach.coordinates[0], beach.coordinates[1]),
      width: 100,
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            // Deselect previous beach if any
            if (selectedBeach != null) {
              selectedBeach!.isSelected = false;
            }

            // Select new beach
            selectedBeach = beach;
            beach.isSelected = true;

            // Move map to selected beach
            _mapController.move(
              LatLng(beach.coordinates[0], beach.coordinates[1]),
              14,
            );

            // Fetch nearby places for selected beach
            _fetchNearbyPOIs();
          });
          _showBeachDetails(beach);
        },
        child: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: beach.isSelected ? Colors.blue.shade700 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: beach.isSelected ? Colors.amber : Colors.blue,
                  width: beach.isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.beach_access,
                  color: beach.isSelected ? Colors.white : Colors.blue,
                  size: 32,
                ),
              ),
            ),
            if (beach.temperature != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getTemperatureColor(beach.temperature!),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '${beach.temperature!.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }



  void _showKochiDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kochi City Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude: $kochilat'),
            Text('Longitude: $kochilong'),
            if (kochiTemperature != null)
              Text(
                'Temperature: ${kochiTemperature!.toStringAsFixed(1)}°C',
                style: TextStyle(
                  color: _getKochiMarkerColor(),
                  fontWeight: FontWeight.bold,
                ),
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

  // Heatmap building function
  List<CircleMarker> _buildHeatmapCircles() {
    if (selectedLocation?.temperature == null) return [];

    final baseColor = _getTemperatureColor(selectedLocation!.temperature!);
    final location = LatLng(
        selectedLocation!.coordinates[0], selectedLocation!.coordinates[1]);

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
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beach & Nearby Places'),
        backgroundColor: Colors.blue, // Basic blue color
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
                      selectedLocation?.coordinates[0] ?? 9.9673, // Default to Fort Kochi
                      selectedLocation?.coordinates[1] ?? 76.2367,
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
                          ? beaches.expand((beach) => _buildHeatmapCircles()).toList()
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

// Helper method for temperature color
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 24 && temperature <= 30) {
      return Colors.green.shade400;  // Safe range
    } else if ((temperature >= 20 && temperature < 24) ||
        (temperature > 30 && temperature <= 33)) {  // Fixed range for moderate
      return Colors.yellow.shade700;
    } else if ((temperature >= 18 && temperature < 20) ||
        (temperature > 33 && temperature <= 35)) {  // Fixed range for cautious
      return Colors.orange;
    } else {
      return Colors.red;  // Unsafe range (< 18 or > 35)
    }


}  Marker _buildPoiMarker(PointOfInterest poi) {
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
    if (beach == null) return; // Add early return if beach is null

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(beach.name ?? 'Unknown Beach'), // Add null check for name
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (beach.location != null) // Add null check for location
              Text('Location: ${beach.location}'),
            if (beach.coordinates != null &&
                beach.coordinates.length >= 2) // Add null check for coordinates
              Text(
                  'Latitude: ${beach.coordinates[0]}\nLongitude: ${beach.coordinates[1]}'),
            if (beach.temperature != null) // Add null check for temperature
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
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
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

  // Modify the POI fetching to only fetch for the selected beach
  Future<void> _fetchNearbyPOIs() async {
    if (selectedBeach == null) return;

    setState(() => isLoading = true);
    pointsOfInterest.clear();

    final types = {
      'restaurant': '[amenity=restaurant]',
      'hotel': '[tourism=hotel]',
      'tourist_place': '[tourism~"museum|attraction|viewpoint|artwork|gallery"]',
      'medical': '[amenity~"hospital|clinic|doctors|pharmacy"]',
    };

    for (var entry in types.entries) {
      if (!selectedFilters.contains(entry.key)) continue;

      try {
        final query = '''
        [out:json][timeout:25];
        (
          node${entry.value}(around:2000, ${selectedBeach!.coordinates[0]}, ${selectedBeach!.coordinates[1]});
          way${entry.value}(around:2000, ${selectedBeach!.coordinates[0]}, ${selectedBeach!.coordinates[1]});
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
              final lat = element['lat'] ?? element['center']?['lat'];
              final lon = element['lon'] ?? element['center']?['lon'];

              if (lat != null && lon != null) {
                final distance = _calculateDistance(
                  selectedBeach!.coordinates[0],
                  selectedBeach!.coordinates[1],
                  lat.toDouble(),
                  lon.toDouble(),
                );

                if (distance <= 2) { // Only show places within 2km
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
        }
      } catch (e) {
        debugPrint('Error fetching ${entry.key}s: $e');
      }
    }

    setState(() => isLoading = false);
  }
  Future<void> _fetchPOIsForBeach(Beach beach) async {
    final types = {
      'restaurant': '[amenity=restaurant]',
      'hotel': '[tourism=hotel]',
      'tourist_place': '[tourism~"museum|attraction|viewpoint|artwork|gallery"]',
      'medical': '[amenity~"hospital|clinic|doctors|pharmacy"]', // Added medical places
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

    return details.isEmpty
        ? 'No additional information available'
        : details.join('\n');
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


  IconData _getPoiIcon(String type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'tourist_place':
        return Icons.photo_camera;
      case 'medical':
        return Icons.local_hospital;
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
      case 'medical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

// Update the _buildFilterChips method to include medical filter
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        children: [
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
          FilterChip(
            label: const Text('Medical Places'),
            selected: selectedFilters.contains('medical'),
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  selectedFilters.add('medical');
                } else {
                  selectedFilters.remove('medical');
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
                children: [],
              ),
              _legendItem(Colors.green.shade400, 'Safe: 24-30°C'),
              _legendItem(Colors.yellow.shade700, 'Moderate: 20-23°C & 31-33°C'),
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
