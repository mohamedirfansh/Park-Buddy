import 'package:flutter/material.dart';
import 'package:park_buddy/boundary/CarparkInfoPage.dart';
import 'package:park_buddy/control/TabsManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';

import 'LocationManager.dart';

///This control class is responsible for displaying the appropriate screens by calling the right route functions.
class ScreenManager {
  ///Based on the name of the route, generates a route to push on the Navigator.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/carparkinfopage':
        var carparkData = args as List;
        ///Arguments passed as the carpark code, the user's location data and carparkAvailability.
        return MaterialPageRoute(
            builder: (_) => CarparkInfoPage(carparkData[0], carparkData[1], carparkData[2]));
        break;
      case '/multitabview':
        ///The multitab view consists of both the MapViewWithSearch and the CarparkListView.
        return MaterialPageRoute(builder: (_) => MultiTabView());
        break;
      default:
        ///Default Error route.
        return _errorRoute();
    }

    return _errorRoute();
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

  ///Opens a dynamic info page
  ///
  /// @param carparkCode The unique carpark code for identifying the carpark
  /// @param context the BuildContext for the Navigator
  /// @param carparkAvailability The CarparkAvailability object that contains the latest data.
  static void openDynamicInfoPage(BuildContext context, String carparkCode, CarparkAvailability carparkAvailability) async {
    Navigator.pushNamed(context, '/carparkinfopage',
        arguments: [carparkCode, await LocationManager.currentLocation, carparkAvailability]);
  }
}
