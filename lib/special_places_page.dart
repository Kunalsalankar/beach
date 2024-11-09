import 'package:flutter/material.dart';

class SpecialPlacesPage extends StatelessWidget {
  final Map<String, dynamic> beach;

  SpecialPlacesPage({required this.beach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Special Places near ${beach['name']}'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Special Places to visit near ${beach['name']}'),
      ),
    );
  }
}
