import 'package:flutter/material.dart';
import 'package:park_buddy/view/TabsPage.dart';
import 'package:park_buddy/model/CarparkCSV.dart';
import 'package:park_buddy/route_generator.dart';
import 'package:park_buddy/view/MapViewWithSearch.dart';

import 'model/DatabaseManager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Preload csv data
  CarParkCSV.loadData();
  await DatabaseManager.pullCarparkAvailability(DateTime.now());
  DatabaseManager.printAllCarparks();
  await DatabaseManager.deleteAllCarparkBefore(DateTime.now());
  DatabaseManager.printAllCarparks();

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: Scaffold(
        body: MultiTabView(),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF06E2B3),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
//TODO: tutorial
    );
  }
}
