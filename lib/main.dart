import 'package:flutter/material.dart';
import 'model/CarparkCSV.dart';
import 'route_generator.dart';
import 'view/SearchBar.dart';

void main() {
  runApp(MyApp());
  //Preload csv data
  CarParkCSV.loadData();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: Scaffold(
        body: Stack(
          children: [
            SearchBar(),
          ]
        ),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF06E2B3),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
//TODO: tutorial
    );
  }
}
