// varsoli.dart
import 'package:flutter/material.dart';
import 'beach_detail.dart';

class VarsoliBeachesPage extends StatefulWidget {
  const VarsoliBeachesPage({Key? key}) : super(key: key);

  @override
  _VarsoliBeachesPageState createState() => _VarsoliBeachesPageState();
}

class _VarsoliBeachesPageState extends State<VarsoliBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Kappil Beach',
      'location': 'Varsoli, Kerala',
      'image': 'assets/files/img_14.png',
      'coordinates': [11.7416, 75.4898],
      'description': 'A beautiful, secluded beach with scenic backwaters, perfect for nature lovers and those seeking tranquility. The coconut groves and gentle waves make it ideal for peaceful walks and quiet picnics.'
    },
    {
      'name': 'Odayam Beach',
      'location': 'Varsoli, Kerala',
      'image': 'assets/files/img_15.png',
      'coordinates': [11.7281, 75.4812],
      'description': 'A charming beach known for its laid-back vibe and local fishing culture. It’s less crowded, offering a serene environment ideal for relaxing and enjoying stunning sunset views over the Arabian Sea.'
    },
    {
      'name': 'Puthenthope Beach',
      'location': 'Varsoli, Kerala',
      'image': 'assets/files/img_16.png',
      'coordinates': [8.5241, 76.8834],
      'description': 'Known for its clean sands and picturesque landscape, Puthenthope Beach is a perfect spot for family outings and evening strolls. The beach is surrounded by lush greenery and has a peaceful atmosphere.'
    },
    {
      'name': 'Anjengo Beach',
      'location': 'Varsoli, Kerala',
      'image': 'assets/files/img_17.png',
      'coordinates': [8.6848, 76.7478],
      'description': 'This historic beach is close to the Anjengo Fort and is known for its serene beauty and cultural significance. It’s a perfect mix of history and natural beauty, with a peaceful shoreline ideal for quiet relaxation.'
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
          'Varsoli Beaches',
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
