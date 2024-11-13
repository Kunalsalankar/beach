import 'package:flutter/material.dart';
import 'calcungata.dart';
import 'kochi.dart';
import 'kovalam.dart';
import 'Varsoli.dart';
import 'Anjuna.dart';
import 'Alibag.dart';
import 'Visakhapatnam.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<Map<String, dynamic>> beaches = [
    {
      'name': 'Kochi',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/kochi.png',
      'description': 'A serene beach known for its pristine waters and fishing activities. This beautiful...',
      'coordinates': [9.9672, 76.2444],
      'activities': ['Fishing', 'Sunset viewing', 'Photography'],
      'routeName': 'kochi'
    },
    {
      'name': 'Visakhapatnam',
      'location': 'Andhra Pradesh',
      'image': 'assets/files/img_26.png',
      'description': 'A coastal city with beautiful beaches, rich history, and scenic views of the Bay of Bengal.',
      'coordinates': [17.6868, 83.2185],
      'activities': ['Beach activities', 'Historical tours', 'Photography', 'Fishing'],
      'routeName': 'visakhapatnam'
    }

    // Add other beaches here
  ];

  List<Map<String, dynamic>> filteredBeaches = [];
  String searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    filteredBeaches = beaches;
  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredBeaches = beaches.where((beach) {
        final name = beach['name']?.toString().toLowerCase() ?? '';
        final location = beach['location']?.toString().toLowerCase() ?? '';
        return name.contains(searchQuery) || location.contains(searchQuery);
      }).toList();
    });
  }

  void navigateToBeachPage(BuildContext context, Map<String, dynamic> beach) {
    final routeName = beach['routeName']?.toString().toLowerCase() ?? '';

    switch (routeName) {
      case 'kochi':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KochiBeachesPage()),
        );
        break;
      case 'calangute':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalanguteBeachesPage()),
        );
        break;
      case 'kovalam':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KovalamBeachesPage()),
        );
        break;
      case 'varsoli':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VarsoliBeachesPage()),
        );
        break;
      case 'anjuna':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnjunaBeachesPage()),
        );
        break;
      case 'alibag':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AlibagBeachesPage()),
        );
        break;
      case 'visakhapatnam':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisakhapatnamBeachesPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kochi Beaches",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar Container
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a beach...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onChanged: updateSearchQuery,
              ),
            ),
          ),
          // Beach List
          Expanded(
            child: filteredBeaches.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No beaches found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredBeaches.length,
              itemBuilder: (context, index) {
                final beach = filteredBeaches[index];
                return GestureDetector(
                  onTap: () => navigateToBeachPage(context, beach),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Beach Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.asset(
                            beach['image'] ?? 'assets/files/placeholder.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Beach Information
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                beach['name'] ?? 'Unnamed Beach',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    beach['location'] ?? 'Unknown Location',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                beach['description'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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