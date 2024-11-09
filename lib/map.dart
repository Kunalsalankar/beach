import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> beaches = [
    {
      "name": "Kochi Beach",
      "city": "Kochi",
      "state": "Kerala",
      "coordinates": LatLng(9.9356, 76.2813),
      "description": "A beautiful beach known for its stunning sunsets and Chinese fishing nets."
    },
    {
      "name": "Calangute Beach",
      "city": "Calangute",
      "state": "Goa",
      "coordinates": LatLng(15.5494, 73.7535),
      "description": "One of the most popular beaches in Goa, known for its nightlife and water sports."
    },

    {
      "name": "Baga Beach",
      "city": "Goa",
      "state": "Goa",
      "coordinates": LatLng(15.5524, 73.7517),
      "description": "Famous for its vibrant nightlife and water sports."
    },
    {
      "name": "Calangute Beach",
      "city": "Calangute",
      "state": "Goa",
      "coordinates": LatLng(15.5494, 73.7535),
      "description": "One of the most popular beaches in Goa, known for its nightlife and water sports."
    },
    {
      "name": "Kovalam Beach",
      "city": "Kovalam",
      "state": "Kerala",
      "coordinates": LatLng(8.3985, 76.9969),
      "description": "Famous for its crescent-shaped beaches and lighthouses."
    },
    {
      "name": "RK Beach",
      "city": "Visakhapatnam",
      "state": "Andhra Pradesh",
      "coordinates": LatLng(17.6880, 83.3042),
      "description": "Known for its picturesque beach promenade and sunset views."
    },
    {
      "name": "Alibag Beach",
      "city": "Alibag",
      "state": "Maharashtra",
      "coordinates": LatLng(18.6400, 72.8339),
      "description": "A sandy beach popular for its scenic views and water sports."
    },
    {
      "name": "Varsoli Beach",
      "city": "Alibag",
      "state": "Maharashtra",
      "coordinates": LatLng(18.3462, 72.8252),
      "description": "Known for its calm waters and peaceful surroundings."
    },
    {
      "name": "Varkala Beach",
      "city": "Varkala",
      "state": "Kerala",
      "coordinates": LatLng(8.7330, 76.7116),
      "description": "Known for its cliffs and stunning views."
    },
    {
      "name": "Anjuna Beach",
      "city": "Anjuna",
      "state": "Goa",
      "coordinates": LatLng(15.5733, 73.7410),
      "description": "Famous for its flea market and vibrant atmosphere."
    },
    {
      "name": "Juhu Beach",
      "city": "Mumbai",
      "state": "Maharashtra",
      "coordinates": LatLng(19.0974, 72.8264),
      "description": "A popular beach known for its street food and Bollywood connections."
    },
    {
      "name": "Puri Beach",
      "city": "Puri",
      "state": "Odisha",
      "coordinates": LatLng(19.8145, 85.8312),
      "description": "Known for its golden sands and the annual Rath Yatra."
    },
    {
      "name": "Mahabalipuram Beach",
      "city": "Mahabalipuram",
      "state": "Tamil Nadu",
      "coordinates": LatLng(12.6192, 80.2029),
      "description": "Famous for its rock-cut temples and historical significance."
    },


    // Add more beaches here if needed
  ];
  List<Map<String, dynamic>> _filteredBeaches = [];
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _filteredBeaches = beaches;
  }

  void _filterResults(String query) {
    setState(() {
      _filteredBeaches = beaches
          .where((beach) =>
          beach["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<String> _getWeather(double lat, double lon) async {
    final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final weather = data['current_weather'];
      return "Current temperature: ${weather['temperature']}°C, Wind Speed: ${weather['windspeed']} m/s";
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  void _showBeachDetails(Map<String, dynamic> beach) async {
    final weatherInfo = await _getWeather(
        beach["coordinates"].latitude, beach["coordinates"].longitude);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(beach["name"]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${beach["city"]}, ${beach["state"]}"),
              SizedBox(height: 10),
              Text(beach["description"]),
              SizedBox(height: 10),
              Text(weatherInfo, style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blue)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map - Shore Shield"),
        backgroundColor: Colors.blue, // Replace 'Colors.blue' with your preferred color
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterResults,
              decoration: InputDecoration(
                hintText: "Search for a beach...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                // Initial zoom level
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),

              ],
            ),
          ),
          if (_filteredBeaches.isNotEmpty)
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: _filteredBeaches.length,
                itemBuilder: (context, index) {
                  final beach = _filteredBeaches[index];
                  return ListTile(
                    title: Text(beach["name"]),
                    onTap: () {
                      _mapController.move(beach["coordinates"], 10.0);
                      _showBeachDetails(beach);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}