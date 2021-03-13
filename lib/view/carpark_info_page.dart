import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:park_buddy/model/CarparkCSV.dart';
import 'package:park_buddy/model/CarparkInfo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park_buddy/Histogram.dart';


class CarparkInfoPage extends StatefulWidget {
  final String carparkCode;
  final LocationData userLocation;
  CarparkInfoPage(this.carparkCode, this.userLocation); // constructor: pass info of which carpark

  @override
  _CarparkInfoPageState createState() => _CarparkInfoPageState(this.carparkCode, this.userLocation);
}

class _CarparkInfoPageState extends State<CarparkInfoPage> {
  _CarparkInfoPageState(this.carparkCode, this.currentLocation);
  final String carparkCode;
  final LocationData currentLocation;

  double getDistance(double carparkLat, double carparkLong) {
    final double distance = Geolocator.distanceBetween(carparkLat, carparkLong,
        currentLocation.latitude, currentLocation.longitude);
    return distance * 0.001; //distance in kilometers
  }

  @override
  Widget build(BuildContext context) {
    CarparkInfo carpark = CarParkCSV.carparkList.where((carpark) =>
    carpark.carparkCode == widget.carparkCode).elementAt(0);
     // TODO: remove once destination select is working
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpark ${widget.carparkCode}'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        child: ListView(
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  _titleSection(carpark),
                  _infoSection(carpark),
                ],
              ),
            ),
            Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    Text(
                        "Carpark History",
                        style: TextStyle(
                            fontSize: 15
                        )
                    ),
                    Histogram(),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
  Widget _titleSection(CarparkInfo carpark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              carpark.address,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Text(
              'Carpark ${widget.carparkCode}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 17,
              )
          )
        ],
      ),
    );
  }

  Widget _infoSection(CarparkInfo carpark) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  "95/100 lots",
                  //TODO: get carpark availability info dynamically
                  style: TextStyle(
                      fontSize: 15
                  )
              ),
              Text(
                  "${getDistance(
                      carpark.latlng.latitude, carpark.latlng.longitude)
                      .toStringAsFixed(1)} km", // format to 1 decimal place
                  style: TextStyle(
                      fontSize: 15
                  )
              )
            ]
        )
    );
  }
}

//TODO: button to link to google maps app for directions (figure out function call from the default Marker onTap behaviour)
//TODO: histogram (queried on demand, show current time data)