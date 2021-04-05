import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/entity/Histogram.dart';

class CarparkInfoPage extends StatefulWidget {
  final String carparkCode;
  final LocationData userLocation;
  final CarparkAvailability carparkAvailability;
  CarparkInfoPage(this.carparkCode,
      this.userLocation, this.carparkAvailability); // constructor: pass info of which carpark

  @override
  _CarparkInfoPageState createState() =>
      _CarparkInfoPageState(this.carparkCode, this.userLocation, this.carparkAvailability);
}

class _CarparkInfoPageState extends State<CarparkInfoPage> {
  _CarparkInfoPageState(this.carparkCode, this.currentLocation, this.carparkAvailability);
  final String carparkCode;
  final LocationData currentLocation;
  final CarparkAvailability carparkAvailability;

  double getDistance(double carparkLat, double carparkLong) {
    final double distance = Geodesy().distanceBetweenTwoGeoPoints(LatLng(carparkLat, carparkLong), LatLng(currentLocation.latitude, currentLocation.longitude));
    return distance * 0.001; //distance in kilometers
  }

  @override
  Widget build(BuildContext context) {
    CarparkInfo carpark = CarparkInfoManager.carparkList
        .where((carpark) => carpark.carparkCode == widget.carparkCode)
        .elementAt(0);
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
                child: _carparkHistorySection(carparkCode)
              ),
            Card(
                elevation: 4,
                margin: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListTile(
                  leading: ImageIcon(AssetImage("assets/images/Google_Maps_Icon.png"),
                  ),
                  title: Text("Get directions with Google Maps"),
                  onTap: () => goToGoogleMaps(carpark),
                )
            )
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
          Text('Carpark ${widget.carparkCode}',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 17,
              ))
        ],
      ),
    );
  }

  Widget _carparkHistorySection(String carparkCode) {
    return Histogram(carparkCode);
  }

  Widget _carparkAvailabilityInfoSection(
      CarparkInfo carpark, CarparkAvailability carparkAvailability) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(
              "${carparkAvailability.lotsAvailableC}/${carparkAvailability.totalLotsC} lots available",
              style: TextStyle(fontSize: 15)),
          Text(
              "${getDistance(carpark.latlng.latitude, carpark.latlng.longitude).toStringAsFixed(1)} km away", // format to 1 decimal place
              style: TextStyle(fontSize: 15))
        ]));
  }

  Widget _carparkInfoSectionBuilder(
      BuildContext context, CarparkInfo carpark) {
    if (carparkAvailability != null){
      return _carparkAvailabilityInfoSection(carpark, carparkAvailability);
    }
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

  Future<CarparkAvailability> _getCarparkAvailability(
      CarparkInfo carpark) async {
    return await CarparkAPIInterface.getSingleCarparkAvailability(
        DateTime.now(), carpark);
  }

  Widget _apiLoadingWidget(CarparkInfo carpark) {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("Loading data...", style: TextStyle(fontSize: 15)),
          Text(
              "${getDistance(carpark.latlng.latitude, carpark.latlng.longitude).toStringAsFixed(1)} km away", // format to 1 decimal place
              style: TextStyle(fontSize: 15))
        ]));
  }

  Widget _emptyResultsWidget() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("API unavailable. Please try again later.",
              style: TextStyle(fontSize: 15)),
        ]));
  }

  Future<void> goToGoogleMaps(CarparkInfo info) async {
    final availableMaps = await MapLauncher.installedMaps;
    await availableMaps.first.showDirections(
      destinationTitle: info.address,
      destination: Coords(info.latlng.latitude, info.latlng.longitude),
    );
  }
}

//TODO: histogram (queried on demand, show current time data)
