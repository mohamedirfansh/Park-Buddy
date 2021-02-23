import 'package:flutter/material.dart';
import 'route_generator.dart';
import 'map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: MapView(),
      theme: ThemeData(
        primaryColor: const Color(0xFF06E2B3),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,

    );
  }
}
