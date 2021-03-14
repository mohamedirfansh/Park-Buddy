import 'package:flutter/material.dart';
import 'package:park_buddy/view/MapView.dart';
import 'package:park_buddy/view/CarparkInfoPage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/carparkinfopage':
        var carparkData = args as List;
        return  MaterialPageRoute(builder: (_) => CarparkInfoPage(carparkData[0], carparkData[1]));
        break;
      case '/listview':
        break;
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Error Page'),
          ),
          body: Center(child: Text('ERROR')));
    });
  }
}
