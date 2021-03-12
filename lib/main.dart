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
  runApp(MyApp());
  await DatabaseManager.pullCarparkAvailability(DateTime.now());
  /*
  print(list.length);
  print(list[2073].carparkNumber);
  print(list[2073].lotsAvailable);
  print(list[2073].lotType);
  print(list[2073].timestamp);
  print(list[2073].totalLots);
  print(list[2073].updateDatetime);
  */
  await DatabaseManager.getAllCarparks();
  await DatabaseManager.deleteAllCarparkBefore(DateTime.now());
  print("new query");
  await DatabaseManager.getAllCarparks();
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
