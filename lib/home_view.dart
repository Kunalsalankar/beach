import 'package:flutter/material.dart';
import 'beach_detail.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> beaches = [
    {
      'name': 'Baga Beach',
      'location': 'Goa',
      'image': 'assets/files/baga.jpg',
      'description': 'Famous for its vibrant nightlife and water sports.',
      'coordinates': [15.5524, 73.7517]
    },
    {
      'name': 'Calangute Beach',
      'location': 'Goa',
      'image': 'assets/files/calcanguta.jpg',
      'description': 'One of the most popular beaches in Goa, known for its nightlife and water sports.',
      'coordinates': [15.5494, 73.7535]
    },
    {
      'name': 'Kovalam Beach',
      'location': 'Kerala',
      'image': 'assets/files/kovalam.jpg',
      'description': 'Famous for its crescent-shaped beaches and lighthouses.',
      'coordinates': [8.3985, 76.9969]
    },
    {
      'name': 'RK Beach',
      'location': 'Andhra Pradesh',
      'image': 'assets/files/Rk_beach.jpg',
      'description': 'Known for its picturesque beach promenade and sunset views.',
      'coordinates': [17.6880, 83.3042]
    },
    {
      'name': 'Alibag Beach',
      'location': 'Maharashtra',
      'image': 'assets/files/Alibag.png',
      'description': 'A sandy beach popular for its scenic views and water sports.',
      'coordinates': [18.6400, 72.8339]
    },
    {
      'name': 'Varsoli Beach',
      'location': 'Maharashtra',
      'image': 'assets/files/varsoli.png',
      'description': 'Known for its calm waters and peaceful surroundings.',
      'coordinates': [18.3462, 72.8252]
    },
    {
      'name': 'Varkala Beach',
      'location': 'Kerala',
      'image': 'assets/files/varkala.png',
      'description': 'Known for its cliffs and stunning views.',
      'coordinates': [8.7330, 76.7116]
    },
    {
      'name': 'Anjuna Beach',
      'location': 'Goa',
      'image': 'assets/files/anguna.png',
      'description': 'Famous for its flea market and vibrant atmosphere.',
      'coordinates': [15.5733, 73.7410]
    },
    {
      'name': 'Juhu Beach',
      'location': 'Maharashtra',
      'image': 'assets/files/img.png',
      'description': 'A popular beach known for its street food and Bollywood connections.',
      'coordinates': [19.0974, 72.8264]
    },
    {
      'name': 'Puri Beach',
      'location': 'Odisha',
      'image': 'assets/files/img_1.png',
      'description': 'Known for its golden sands and the annual Rath Yatra.',
      'coordinates': [19.8145, 85.8312]
    },
    {
      'name': 'Mahabalipuram Beach',
      'location': 'Tamil Nadu',
      'image': 'assets/files/img_2.png',
      'description': 'Famous for its rock-cut temples and historical significance.',
      'coordinates': [12.6192, 80.2029]
    },
    // Add other beach data with coordinates as needed
  ];

  List<Map<String, dynamic>> filteredBeaches = [];

  @override
  void initState() {
    super.initState();
    filteredBeaches = beaches;
    _searchController.addListener(_filterBeaches);
  }

  void _filterBeaches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBeaches = beaches.where((beach) {
        return beach['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beach Explorer'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a beach...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              beach['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            beach['name'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                beach['location'],
                                style: TextStyle(color: Colors.grey),
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
