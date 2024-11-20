import 'package:flutter/material.dart';

class HotelsPage extends StatelessWidget {
  final Map<String, dynamic> beach;

  HotelsPage({required this.beach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${beach['name']} Hotels & Restaurants'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Hotels & Restaurants near ${beach['name']}'),
      ),
    );
  }
}
