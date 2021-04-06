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
import 'package:park_buddy/control/DistanceFilterManager.dart';

class CarparkListView extends StatefulWidget {
  @override
  _CarparkListViewState createState() => _CarparkListViewState();

  static _CarparkListViewState of(BuildContext context) =>
      context.findAncestorStateOfType<_CarparkListViewState>();
}

class _CarparkListViewState extends State<CarparkListView> {
  LocationData currentLocation;
  double _chosenDist = 0.5;

  set distance(double val) {
    setState(() {
      _chosenDist = val;
    });
  }

  Future<LocationData> getUserLocation() async {
    if (LocationManager.locationModeSelf) {
      return await LocationManager.currentLocation;
    } else {
      return LocationManager.intendedLocation;
    }
  }

  Widget build(BuildContext context) {
    void _showDistancePanel() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: DistFilterManager(),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('List of Carparks'),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.settings),
            label: Text(
              'Change Distance',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _showDistancePanel(),
          )
        ],
      ),
      body: FutureBuilder(
          future: getUserLocation(),
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              //Loading
              return _loadingWidget(false);
            } else if (snapshot.hasError) {
              return _loadingWidget(true);
            } else if (snapshot.hasData && snapshot.data != null) {
              return CarparkListManager(_chosenDist)
                  .constructList(snapshot.data);
            } else {
              //Error
              return Container(child: Text("Error"));
            }
          }),
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
