import 'package:flutter/material.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/ScreenManager.dart';
import 'package:park_buddy/boundary/OnBoardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'control/TabsManager.dart';

bool viewTut;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  viewTut = pref.getBool("view_tutorial") ?? true;
  await pref.setBool("view_tutorial", false);
  ///Preload csv data before app startup.
  await CarparkInfoManager.loadDataFromCSV();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkBuddy',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(children: [
          //MultiTabView(),
          viewTut ? OnBoardingPage() : TabsManager(),
        ]),
      ),
      theme: ThemeData(
        primaryColor: const Color(0xFF06E2B3),
      ),
      onGenerateRoute: ScreenManager.generateRoute,
    );
  }
}
