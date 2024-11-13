// anjuna.dart
import 'package:flutter/material.dart';
import 'beach_detail.dart';

class AnjunaBeachesPage extends StatefulWidget {
  const AnjunaBeachesPage({Key? key}) : super(key: key);

  @override
  _AnjunaBeachesPageState createState() => _AnjunaBeachesPageState();
}

class _AnjunaBeachesPageState extends State<AnjunaBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Chapora Beach',
      'location': 'Anjuna, Goa',
      'image': 'assets/files/img_18.png',
      'coordinates': [15.6011, 73.7364],
      'description': 'A beach known for its famous Chapora Fort nearby. Offers stunning views of the coastline and vibrant nightlife, making it a favorite spot for tourists and photographers.',
    },
    {
      'name': 'Ozran Beach',
      'location': 'Anjuna, Goa',
      'image': 'assets/files/img_19.png',
      'coordinates': [15.5929, 73.7434],
      'description': 'A secluded beach with rocky outcrops and calm waters. Ideal for a peaceful day by the sea, with many small beach shacks serving local delicacies.',
    },
    {
      'name': 'Ashwem Beach',
      'location': 'Anjuna, Goa',
      'image': 'assets/files/img_20.png',
      'coordinates': [15.6583, 73.7317],
      'description': 'A tranquil and scenic beach famous for its clean sands and gentle waves. Popular among those looking for a quiet beach experience and a place to relax.',
    },
    {
      'name': 'Betalbatim Beach',
      'location': 'Anjuna, Goa',
      'image': 'assets/files/img_21.png',
      'coordinates': [15.2861, 73.9240],
      'description': 'A beautiful beach known for its golden sands and stunning sunsets. Less crowded than nearby beaches, making it a perfect spot for relaxation and evening walks.',
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
          'Anjuna Beaches',
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
