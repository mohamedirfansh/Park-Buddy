import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';

import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/CarparkListManager.dart';
import 'package:park_buddy/control/LocationManager.dart';
import 'package:park_buddy/entity/CarparkCard.dart';

class CarparkListView extends StatefulWidget {
  @override
  _CarparkListViewState createState() => _CarparkListViewState();
}

class _CarparkListViewState extends State<CarparkListView> {
  LocationData currentLocation;

  Future<LocationData> getUserLocation() async {
    if (LocationManager.locationModeSelf) {
      return await LocationManager.currentLocation;
    } else {
      return LocationManager.intendedLocation;
    }
  }

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
