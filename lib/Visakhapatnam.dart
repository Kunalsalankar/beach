// kochi.dart
import 'package:flutter/material.dart';
import 'beach_detail.dart';

class VisakhapatnamBeachesPage extends StatefulWidget {
  const VisakhapatnamBeachesPage({Key? key}) : super(key: key);

  @override
  _VisakhapatnamBeachesPageState createState() => _VisakhapatnamBeachesPageState();
}

class _VisakhapatnamBeachesPageState extends State<VisakhapatnamBeachesPage> {
  final List<Map<String, dynamic>> allBeaches = [
    {
      'name': 'Rushikonda Beach',
      'location': 'Visakhapatnam, Andhra Pradesh',
      'image': 'assets/files/img_27.png',
      'coordinates': [17.7569, 83.3784],
      'description': 'Known for its golden sands and crystal-clear waters. Rushikonda is ideal for swimming, surfing, and water sports. A popular spot for tourists and locals alike, offering breathtaking views of the Eastern Ghats.',
    },
    {
      'name': 'Bheemili Beach',
      'location': 'Visakhapatnam, Andhra Pradesh',
      'image': 'assets/files/img_28.png',
      'coordinates': [17.8903, 83.4521],
      'description': 'Bheemili Beach combines historical charm with natural beauty. This quiet, pristine beach is ideal for a peaceful retreat and is dotted with colonial monuments and ruins.',
    },
    {
      'name': 'Lawson\'s Bay Beach',
      'location': 'Visakhapatnam, Andhra Pradesh',
      'image': 'assets/files/img_29.png',
      'coordinates': [17.7289, 83.3431],
      'description': 'A calm and scenic beach known for its gentle waves. Perfect for a peaceful day by the sea with opportunities for swimming and sunbathing, offering serene views of the bay and lush greenery.',
    },
    {
      'name': 'Sagar Nagar Beach',
      'location': 'Visakhapatnam, Andhra Pradesh',
      'image': 'assets/files/img_30.png',
      'coordinates': [17.7622, 83.3721],
      'description': 'A quiet and less-crowded beach with stunning ocean views. A hidden gem for relaxation and evening strolls, with nearby local eateries offering authentic cuisine.',
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
