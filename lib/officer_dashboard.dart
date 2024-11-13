import 'package:flutter/material.dart';

class OfficerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Officer Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(title: 'Monitor and Ensure Beach Safety'),
            SizedBox(height: 20),
            OfficerDashboardSection(),
          ],
        ),
      ),
    );
  }
}

class OfficerDashboardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          DashboardCard(
            icon: Icons.warning,
            title: 'Current Beach Alerts',
            description: 'View and manage real-time alerts.',
          ),
          DashboardCard(
            icon: Icons.map,
            title: 'Live Map View',
            description: 'Check beach conditions with live maps.',
          ),
          DashboardCard(
            icon: Icons.people,
            title: 'Crowd Control Tools',
            description: 'Tools to manage beach crowd density.',
          ),
          DashboardCard(
            icon: Icons.eco,
            title: 'Environmental Parameters',
            description: 'View ocean and weather conditions.',
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final String title;
  HeaderSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade200, Colors.blue.shade700]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            'Your control center for monitoring beach safety.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  DashboardCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blueAccent),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
