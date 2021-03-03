import 'package:flutter/material.dart';
import 'package:park_buddy/view/TabsPage.dart';
import 'package:park_buddy/model/CarparkCSV.dart';
import 'package:park_buddy/route_generator.dart';
import 'package:park_buddy/view/MapViewWithSearch.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  //Preload csv data
  CarParkCSV.loadData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: Scaffold(
        body: Stack(children: [
          MapViewWithSearch(),
          TabsPage(),
        ]),
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
