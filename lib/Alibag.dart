// alibag.dart
import 'package:flutter/material.dart';
import 'beach_detail.dart';

class AlibagBeachesPage extends StatefulWidget {
  const AlibagBeachesPage({Key? key}) : super(key: key);

  @override
  _AlibagBeachesPageState createState() => _AlibagBeachesPageState();
}

class _AlibagBeachesPageState extends State<AlibagBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Kihim Beach',
      'location': 'Alibag, Maharashtra',
      'image': 'assets/files/img_22.png',
      'coordinates': [18.7459, 72.8776],
      'description': 'A beautiful beach known for its serene environment and scenic views. Lined with coconut trees, Kihim Beach is popular for its scenic beauty, birdwatching, and wildflowers. Perfect for those looking for a peaceful retreat.'
    },
    {
      'name': 'Nagaon Beach',
      'location': 'Alibag, Maharashtra',
      'image': 'assets/files/img_23.png',
      'coordinates': [18.5920, 72.9107],
      'description': 'A popular beach with clear water and water sports activities. Known for its sandy shoreline and coconut palms, Nagaon Beach is ideal for families and thrill-seekers who enjoy parasailing, banana rides, and jet skiing.'
    },
    {
      'name': 'Mandwa Beach',
      'location': 'Alibag, Maharashtra',
      'image': 'assets/files/img_24.png',
      'coordinates': [18.8110, 72.8775],
      'description': 'A tranquil beach with beautiful views and a ferry connection to Mumbai. Famous for its sunset views and water sports, Mandwa Beach is a favorite for beach lovers and is easily accessible by ferry from Mumbai.'
    },
    {
      'name': 'Akshi Beach',
      'location': 'Alibag, Maharashtra',
      'image': 'assets/files/img_25.png',
      'coordinates': [18.6284, 72.9102],
      'description': 'A clean, quiet beach popular for picnics and fishing. Known for its white sands and crystal-clear waters, Akshi Beach is an ideal destination for family picnics and birdwatching enthusiasts.'
    },
  ];

  List<Map<String, dynamic>> filteredBeaches = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredBeaches = allBeaches;
    searchController.addListener(_filterBeaches);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterBeaches() {
    final String searchTerm = searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        filteredBeaches = allBeaches;
      } else {
        filteredBeaches = allBeaches.where((beach) {
          return beach['name'].toString().toLowerCase().contains(searchTerm) ||
              beach['location'].toString().toLowerCase().contains(searchTerm) ||
              beach['description'].toString().toLowerCase().contains(searchTerm);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alibag Beaches',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
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
                : ListView.builder(
              padding: const EdgeInsets.all(16),
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
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.asset(
                            beach['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beach['name'],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    beach['location'],
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                beach['description'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[800]),
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
