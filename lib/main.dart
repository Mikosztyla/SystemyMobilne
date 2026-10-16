import 'package:flutter/material.dart';

void main() {
  runApp(const BursaApp());
}

class BursaApp extends StatelessWidget {
  const BursaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bursa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F5D62)),
      ),
      home: const Scaffold(
        body: Center(child: Text('Bursa')),
      ),
    );
  }
}
