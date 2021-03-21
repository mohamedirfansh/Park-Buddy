import 'package:flutter/material.dart';

import 'package:park_buddy/boundary/TabsPage.dart';
import 'package:park_buddy/boundary/carpark_info_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/carparkinfopage':
        var carparkCode = args as String;
        return  MaterialPageRoute(builder: (_) => CarparkInfoPage(carparkCode));
        break;
      case '/listview':
        break;
      case '/multitabview':
        return MaterialPageRoute(builder: (_) => MultiTabView());
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
