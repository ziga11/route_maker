import 'package:flutter/material.dart';
import 'package:route_maker/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.indigoAccent.shade700),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
