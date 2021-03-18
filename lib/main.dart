import 'package:flutter/material.dart';
import 'package:park_buddy/view/TabsPage.dart';
import 'package:park_buddy/model/CarparkCSV.dart';
import 'package:park_buddy/route_generator.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Preload csv data
  CarParkCSV.loadData();
  runApp(MyApp());
  /*
  await DatabaseManager.deleteAllCarparkBefore(DateTime.now().toUtc().add(Duration(hours:8)));
  print(DateTime.now().millisecondsSinceEpoch);

  await DatabaseManager.printAllCarparks();
  final stopwatch = Stopwatch()..start();
  await PullDateManager.pullMissingDates();
  stopwatch.stop();
  print('pullMissingDates() executed in ${stopwatch.elapsed}');
  */
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: Scaffold(
        body: Stack(children: [
          MultiTabView(),
        ]),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF06E2B3),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
//TODO: tutorial
    );
  }
}
