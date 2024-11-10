// kovalam.dart
import 'package:flutter/material.dart';
import 'beach_detail.dart';

class KovalamBeachesPage extends StatefulWidget {
  const KovalamBeachesPage({Key? key}) : super(key: key);

  @override
  _KovalamBeachesPageState createState() => _KovalamBeachesPageState();
}

class _KovalamBeachesPageState extends State<KovalamBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Lighthouse Beach',
      'location': 'Kovalam, Kerala',
      'image': 'assets/files/img_11.png',
      'coordinates': [8.3836, 76.9467],
      'description': 'Popular for its towering lighthouse offering panoramic views. A bustling beach known for its picturesque sunsets, water sports, and a variety of restaurants along the shore.',
    },
    {
      'name': 'Hawa Beach',
      'location': 'Kovalam, Kerala',
      'image': 'assets/files/img_12.png',
      'coordinates': [8.3851, 76.9471],
      'description': 'Also known as Eve’s Beach, famous for its tranquil atmosphere. A favorite among visitors for sunbathing and scenic views, providing a calm and less crowded alternative to Lighthouse Beach.',
    },
    {
      'name': 'Samudra Beach',
      'location': 'Kovalam, Kerala',
      'image': 'assets/files/img_13.png',
      'coordinates': [8.3912, 76.9505],
      'description': 'A quiet and less commercialized beach ideal for relaxation. Known for its natural beauty, clear waters, and a peaceful ambiance away from the busy tourist spots.',
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
          'Kovalam Beaches',
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
                                    fontSize: 14, color: Colors.grey[800]),
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
