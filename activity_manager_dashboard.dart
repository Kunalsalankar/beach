import 'package:flutter/material.dart';

class ActivityManagerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Manager Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderSection(title: 'Manage Beach Safety Activities & Alerts'),
            SizedBox(height: 20),
            DashboardSection(),
          ],
        ),
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
            'Your control center for managing beach activities and alerts.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class DashboardSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          DashboardCard(
            icon: Icons.beach_access,
            title: 'Current Beach Conditions',
            description: 'Real-time updates on beach conditions.',
          ),
          DashboardCard(
            icon: Icons.notifications,
            title: 'Create and Manage Alerts',
            description: 'Set up alerts for beach safety.',
          ),
          DashboardCard(
            icon: Icons.schedule,
            title: 'Scheduled Activities',
            description: 'View and manage scheduled activities.',
          ),
          DashboardCard(
            icon: Icons.announcement,
            title: 'Announcements',
            description: 'Post and view announcements.',
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
