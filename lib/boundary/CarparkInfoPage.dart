import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/control/CarparkCSV.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(carpark.address),
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
                  _carparkInfoSectionBuilder(context, carpark),
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

  Widget _carparkAvailabilityInfoSection(CarparkInfo carpark, CarparkAvailability carparkAvailability) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  "${carparkAvailability.lotsAvailableC}/${carparkAvailability.totalLotsC} lots available",
                  style: TextStyle(
                      fontSize: 15
                  )
              ),
              Text(
                  "${getDistance(
                      carpark.latlng.latitude, carpark.latlng.longitude)
                      .toStringAsFixed(1)} km away", // format to 1 decimal place
                  style: TextStyle(
                      fontSize: 15
                  )
              )
            ]
        )
    );
  }

  FutureBuilder<CarparkAvailability> _carparkInfoSectionBuilder(BuildContext context, CarparkInfo carpark) {
    return FutureBuilder(
      future: _getCarparkAvailability(carpark),
      builder: (context, snapshot) {
        if (snapshot.hasData == false && !snapshot.hasError) {
          return _apiLoadingWidget(carpark);
        } else if (snapshot.hasData) {
          return _carparkAvailabilityInfoSection(carpark, snapshot.data);
        } else {
          return _emptyResultsWidget();
        }
      },
    );
  }

  Future<CarparkAvailability> _getCarparkAvailability(CarparkInfo carpark) async {
    return await CarparkAPIInterface.getSingleCarparkAvailability(DateTime.now(), carpark);
  }

  Widget _apiLoadingWidget(CarparkInfo carpark) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  "Loading data...",
                  style: TextStyle(
                      fontSize: 15
                  )
              ),
              Text(
                  "${getDistance(
                      carpark.latlng.latitude, carpark.latlng.longitude)
                      .toStringAsFixed(1)} km away", // format to 1 decimal place
                  style: TextStyle(
                      fontSize: 15
                  )
              )
            ]
        )
    );
  }

  Widget _emptyResultsWidget(){
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  "API unavailable. Please try again later.",
                  style: TextStyle(
                      fontSize: 15
                  )
              ),
            ]
        )
    );
  }
}

//TODO: button to link to google maps app for directions (figure out function call from the default Marker onTap behaviour)
//TODO: histogram (queried on demand, show current time data)