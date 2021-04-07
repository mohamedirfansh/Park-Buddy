import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';

import 'package:park_buddy/control/CarparkListManager.dart';
import 'package:park_buddy/control/LocationManager.dart';

///This view displays all the carparks that the user has searched for in a neat list view.
class CarparkListView extends StatefulWidget {
  @override
  _CarparkListViewState createState() => _CarparkListViewState();
}

class _CarparkListViewState extends State<CarparkListView> {
  LocationData currentLocation;

  ///Gets the user's location. This can be either the user's own location, or the user's intended location,
  /// depending on whether they searched for a destination, or used the recentre button on the map view.
  Future<LocationData> getUserLocation() async {
    if (LocationManager.locationModeSelf) {
      return await LocationManager.currentLocation;
    } else {
      return LocationManager.intendedLocation;
    }
  }

  ///Returns a Future-dependent widget. After checking the user location, we return appropriate widgets based on the Future state.
  /// If the Future is not completed, we show a loading widget.
  /// If not, we call CarparkListManager to construct the list of carparks for us.
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserLocation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return _loadingWidget(false);
          } else if (snapshot.hasError) {
            return _loadingWidget(true);
          } else if (snapshot.hasData && snapshot.data != null) {
            return CarparkListManager().constructList(snapshot.data);
          } else {
            return Container(child: Center(child: Text("Error")));
          }
        }
    );
  }

  ///A simple loading widget with a spinning ring to show loading.
  Widget _loadingWidget(bool error) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitRing(
          color: error ? Colors.purple : Colors.cyan[300],
          size: 50.0,
        ),
      ),
    );
  }
}
