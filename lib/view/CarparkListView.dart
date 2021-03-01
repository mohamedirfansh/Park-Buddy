import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:park_buddy/view/CarparkCard.dart';
import 'package:park_buddy/model/CarparkCSV.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CarparkListView extends StatefulWidget {
  @override
  _CarparkListViewState createState() => _CarparkListViewState();
}

class _CarparkListViewState extends State<CarparkListView> {
  LatLng _center;
  Position currentLocation;

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
  }

  Widget build(BuildContext context) {
    if (_center != null) {
      final carparks = CarParkCSV.dataFilteredByDistance(CarParkCSV.carparkList,
          0.5, LatLng(_center.latitude, _center.longitude));

      return ListView.builder(
        itemCount: carparks.length,
        itemBuilder: (context, index) {
          return CarparkCard(carpark: carparks[index]);
        },
      );
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
