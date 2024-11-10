// kochi.dart
import 'package:flutter/material.dart';
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
    },
    {
      'name': 'Kuzhupilly Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_4.png',
      'coordinates': [10.1055, 76.1849],
      'description': 'Pristine beach with golden sands and peaceful atmosphere. A hidden gem featuring untouched natural beauty, swaying palm trees, and minimal crowds. Ideal for those seeking a quiet beach experience away from the tourist hustle.',
    },
    {
      'name': 'Puthuvype Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_5.png',
      'coordinates': [10.0069, 76.2144],
      'description': 'Famous for its lighthouse and scenic coastal views. The beach is home to Kerala\'s tallest lighthouse and offers spectacular views of the Arabian Sea. Popular for weekend picnics and photography enthusiasts.',
    },
    {
      'name': 'Cherai Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_6.png',
      'coordinates': [10.1327, 76.1791],
      'description': 'Popular beach known for golden sand and seashells. This 15-km long beach is famous for its pristine waters, gentle waves, and unique location between the Arabian Sea and backwaters. Perfect for swimming and watching dolphins.',
    },
    {
      'name': 'Fort Kochi Beach',
      'location': 'Kochi, Kerala',
      'image': 'assets/files/img_7.png',
      'coordinates': [9.9673, 76.2421],
      'description': 'Historic beach with Chinese fishing nets and cultural heritage. A culturally rich coastal area famous for its colonial architecture, art cafes, and iconic Chinese fishing nets. Best known for spectacular sunsets and cultural experiences.',
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
