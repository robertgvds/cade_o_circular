import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CadeOCircularApp());
}

class CadeOCircularApp extends StatelessWidget {
  const CadeOCircularApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadê o Circular',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomePage(),
    );
  }
}
