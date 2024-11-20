import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'beach_detail.dart';

class KochiBeachesPage extends StatefulWidget {
  const KochiBeachesPage({Key? key}) : super(key: key);

  @override
  _KochiBeachesPageState createState() => _KochiBeachesPageState();
}

class _KochiBeachesPageState extends State<KochiBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Munambam Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_3.png',
      'coordinates': [10.1866, 76.1700],
      'description': 'A serene beach known for its pristine waters and fishing activities. This beautiful stretch of coastline offers visitors a peaceful retreat with its golden sands and traditional fishing boats dotting the shore. Perfect for morning walks and experiencing local coastal life.',
      'distance': 0.0, // Added distance field
    },
    {
      'name': 'Kuzhupilly Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_4.png',
      'coordinates': [10.1055, 76.1849],
      'description': 'Pristine beach with golden sands and peaceful atmosphere. A hidden gem featuring untouched natural beauty, swaying palm trees, and minimal crowds. Ideal for those seeking a quiet beach experience away from the tourist hustle.',
      'distance': 0.0,
    },
    {
      'name': 'Puthuvype Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_5.png',
      'coordinates': [10.0069, 76.2144],
      'description': 'Famous for its lighthouse and scenic coastal views. The beach is home to Kerala\'s tallest lighthouse and offers spectacular views of the Arabian Sea. Popular for weekend picnics and photography enthusiasts.',
      'distance': 0.0,
    },
    {
      'name': 'Cherai Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_6.png',
      'coordinates': [10.1327, 76.1791],
      'description': 'Popular beach known for golden sand and seashells. This 15-km long beach is famous for its pristine waters, gentle waves, and unique location between the Arabian Sea and backwaters. Perfect for swimming and watching dolphins.',
      'distance': 0.0,
    },
    {
      'name': 'Fort Kochi Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_7.png',
      'coordinates': [9.9673, 76.2421],
      'description': 'Historic beach with Chinese fishing nets and cultural heritage. A culturally rich coastal area famous for its colonial architecture, art cafes, and iconic Chinese fishing nets. Best known for spectacular sunsets and cultural experiences.',
      'distance': 0.0,
    },
  ];

  List<Map<String, dynamic>> filteredBeaches = [];
  final TextEditingController searchController = TextEditingController();
  Position? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    filteredBeaches = List.from(allBeaches);
    searchController.addListener(_filterBeaches);
    _initializeLocation();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Calculate distance between current location and beach
  double _calculateDistance(List<double> beachCoordinates) {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      beachCoordinates[0],
      beachCoordinates[1],
    ) / 1000; // Convert meters to kilometers
  }

  // Update distances for all beaches
  void _updateBeachDistances() {
    if (_currentPosition != null) {
      for (var beach in filteredBeaches) {
        beach['distance'] = _calculateDistance(List<double>.from(beach['coordinates']));
      }
      // Sort beaches by distance
      filteredBeaches.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      setState(() {});
    }
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable location services.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied. Please grant location permission.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in your device settings.';
      }

      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _errorMessage = null;
      });
      _updateBeachDistances(); // Update distances when location is obtained
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: ${e.toString()}';
      });
    }
  }

  void _filterBeaches() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        filteredBeaches = List.from(allBeaches);
      } else {
        filteredBeaches = allBeaches.where((beach) {
          return beach['name'].toString().toLowerCase().contains(searchTerm) ||
              beach['location'].toString().toLowerCase().contains(searchTerm) ||
              beach['description'].toString().toLowerCase().contains(searchTerm);
        }).toList();
      }
      _updateBeachDistances(); // Update distances after filtering
    });
  }

  Widget _buildLocationInfo() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _initializeLocation,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_currentPosition != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Your location: ${_currentPosition!.latitude.toStringAsFixed(4)}, '
                        '${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _getCurrentLocation,
              child: const Text('Update Location'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beach Explorer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search for a beach...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          _buildLocationInfo(),
          Expanded(
            child: filteredBeaches.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No beaches found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: filteredBeaches.length,
              itemBuilder: (context, index) {
                final beach = filteredBeaches[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BeachDetailPage(beach: beach),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.asset(
                            beach['image'],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beach['name'],
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.grey, size: 16),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      beach['location'],
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Display distance
                              if (_currentPosition != null)
                                Row(
                                  children: [
                                    const Icon(Icons.directions_walk,
                                        color: Colors.grey, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${beach['distance'].toStringAsFixed(1)} km',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}