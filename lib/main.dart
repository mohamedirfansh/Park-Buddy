import 'package:flutter/material.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/ScreenManager.dart';

import 'package:park_buddy/boundary/OnBoardingPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Preload csv data
  CarparkInfoManager.loadDataFromCSV();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      home: Scaffold(
        body: Stack(children: [
          //MultiTabView(),
          OnBoardingPage(),
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
