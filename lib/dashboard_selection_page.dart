import 'package:flutter/material.dart';
import 'SignupPage.dart';
import 'officer_signup.dart';
import 'activity_manager_signup.dart';

class DashboardSelectionPage extends StatelessWidget {
  ButtonStyle _commonButtonStyle() {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      shadowColor: Colors.black26,
      elevation: 5,
      padding: EdgeInsets.symmetric(vertical: 16),
    );
  }

  TextStyle _commonTextStyle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.green,
      letterSpacing: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.green],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    Text(
                      'Choose Your Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                  ],
                ),
              ),
              // Buttons Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDashboardButton(
                        context: context,
                        width: buttonWidth,
                        icon: Icons.person,
                        title: 'User Login',
                        subtitle: 'Access your personal account',
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDashboardButton(
                        context: context,
                        width: buttonWidth,
                        icon: Icons.security,
                        title: 'Officer Dashboard',
                        subtitle: 'For authorized officers only',
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => OfficerSignupPage()),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDashboardButton(
                        context: context,
                        width: buttonWidth,
                        icon: Icons.admin_panel_settings,
                        title: 'Activity Manager',
                        subtitle: 'Manage activities and events',
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ActivityManagerSignupPage()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required BuildContext context,
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: width,
      child: ElevatedButton(
        style: _commonButtonStyle(),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal[100],
              ),
              child: Icon(icon, size: 30, color: Colors.teal[700]),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal[700]),
          ],
        ),
      ),
    );
  }
}
