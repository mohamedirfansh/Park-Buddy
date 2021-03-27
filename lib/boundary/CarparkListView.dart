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
  LatLng _center;
  LocationData currentLocation;

  getUserLocation() async {
    currentLocation = await LocationManager.currentLocation;
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
  }

  Widget build(BuildContext context) {
    if (_center != null) {
      return CarparkListManager().constructList(_center, currentLocation);
    } else {
      getUserLocation();
      return Container(
        color: Colors.white,
        child: Center(
          child: SpinKitRing(
            color: Colors.cyan[300],
            size: 50.0,
          ),
        ),
      );
    }
  }
}
