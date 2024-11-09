import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'hotels_page.dart';
import 'transportation_page.dart';
import 'special_places_page.dart';

class BeachDetailPage extends StatefulWidget {
  final Map<String, dynamic> beach;

  BeachDetailPage({required this.beach});

  @override
  _BeachDetailPageState createState() => _BeachDetailPageState();
}

class _BeachDetailPageState extends State<BeachDetailPage> {
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? hourlyWeatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final latitude = widget.beach['coordinates'][0];
    final longitude = widget.beach['coordinates'][1];

    try {
      // Fetch temperature and windspeed (current weather)
      final currentWeatherUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final currentWeatherResponse = await http.get(Uri.parse(currentWeatherUrl));

      // Fetch humidity and precipitation (hourly data)
      final hourlyWeatherUrl = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,precipitation,windspeed_10m,relative_humidity_2m';
      final hourlyWeatherResponse = await http.get(Uri.parse(hourlyWeatherUrl));

      if (currentWeatherResponse.statusCode == 200 && hourlyWeatherResponse.statusCode == 200) {
        setState(() {
          currentWeatherData = json.decode(currentWeatherResponse.body)['current_weather'];
          hourlyWeatherData = json.decode(hourlyWeatherResponse.body)['hourly'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching weather data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.beach['name']),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            widget.beach['image'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.beach['name'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.beach['location'],
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  widget.beach['description'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWeatherInfo(
                      isLoading ? 'Loading...' : '${currentWeatherData?['temperature']}°C',
                      'Temperature',
                      Icons.thermostat,
                    ),
                    _buildWeatherInfo(
                      isLoading ? 'Loading...' : '${currentWeatherData?['windspeed']} km/h',
                      'Wind Speed',
                      Icons.air,
                    ),
                    _buildWeatherInfo(
                      isLoading ? 'Loading...' : '${hourlyWeatherData?['relative_humidity_2m']?[0] ?? 'N/A'}%',
                      'Humidity',
                      Icons.water,
                    ),
                    _buildWeatherInfo(
                      isLoading ? 'Loading...' : '${hourlyWeatherData?['precipitation']?[0] ?? 'N/A'} mm',
                      'Precipitation',
                      Icons.grain,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildOption(
                  context,
                  'Hotels & Restaurants',
                  Icons.hotel,
                  HotelsPage(beach: widget.beach),
                ),
                _buildOption(
                  context,
                  'Transportation Services',
                  Icons.directions_car,
                  TransportationPage(beach: widget.beach),
                ),
                _buildOption(
                  context,
                  'Special Places',
                  Icons.place,
                  SpecialPlacesPage(beach: widget.beach),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 30),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, Widget destinationPage) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
    );
  }
}
