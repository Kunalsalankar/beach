import 'package:flutter/material.dart';

class TransportationPage extends StatelessWidget {
  final Map<String, dynamic> beach;

  TransportationPage({required this.beach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transportation Services near ${beach['name']}'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Transportation Services near ${beach['name']}'),
      ),
    );
  }
}
