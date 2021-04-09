import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/entity/Histogram.dart';

/// This class is dynamically filled for each Carpark when clicked on in the CarparkListView or MapViewWithSearch.
/// {@category Boundary}
class CarparkInfoPage extends StatefulWidget {
  ///The specific carpark code that is used to dynamically generate the info page
  final String carparkCode;
  ///The user location that is passed from the CarparkListView or MapViewWithSearch
  final LocationData userLocation;
  ///The carpark's current CarparkAvailability that is passed from the CarparkListView or MapViewWithSearch
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

  ///returns the distance between the currentLocation and the carpark location in kilometres
  double getDistance(double carparkLat, double carparkLong) {
    final double distance = Geodesy().distanceBetweenTwoGeoPoints(LatLng(carparkLat, carparkLong), LatLng(currentLocation.latitude, currentLocation.longitude));
    return distance * 0.001; //distance in kilometers
  }

  ///Builds the CarparkInfoPage widget. It comprises of
  /// 1) The title section
  /// 2) The histogram section
  /// 3) The shortcut to Google Maps
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

  ///Creates a widget for the title section of the carpark info page consisting of:
  /// 1) The carpark address
  /// 2) The unique carpark code
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

  ///Creates a widget for the histogram section of the carpark info page consisting of:
  /// 1) The histogram
  ///@see Histogram
  Widget _carparkHistorySection(String carparkCode) {
    return Histogram(carparkCode);
  }

  ///Creates a widget for the availability section of the carpark info page (inside the title section) consisting of:
  /// 1) The current carpark availability
  /// 2) The distance of the carpark from the user's current location
  ///
  /// This is run only when the carparkInfoSectionBuilder is able to return from the Future for getting the carpark availability.
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


  ///Creates the info section in the title section of the infopage.
  ///During the creation of the carpark info page, a CarparkAvailability may or may not be passed. 
  ///This is dependent on whether the user accesses the info page from the map view (where carparkAvailability is not preloaded)
  ///or list view, where carparkAvailability is loaded for all the carparks in the list.
  Widget _carparkInfoSectionBuilder(
      BuildContext context, CarparkInfo carpark) {
    ///Entering from CarparkListView, CarparkAvailability is used to directly create info section
    if (carparkAvailability != null){
      return _carparkAvailabilityInfoSection(carpark, carparkAvailability);
    } else return FutureBuilder(
      ///Entering from MapViewWithSearch, CarparkAvailability is not provided, calling Future _getCarparkAvailability to get data.
      future: _getCarparkAvailability(carpark),
      builder: (context, snapshot) {
        if (snapshot.hasData == false && !snapshot.hasError) {
          ///Show a loading widget while loading API
          return _apiLoadingWidget(carpark);
        } else if (snapshot.hasData) {
          ///Data returned, create info section similar to above.
          return _carparkAvailabilityInfoSection(carpark, snapshot.data);
        } else {
          ///No data returned, show empty results widget
          return _APIUnavailableWidget();
        }
      },
    );
  }

  ///Access the CarparkAPIInterface and get a single carpark's availability
  Future<CarparkAvailability> _getCarparkAvailability(
      CarparkInfo carpark) async {
    return await CarparkAPIInterface.getSingleCarparkAvailability(
        DateTime.now(), carpark);
  }

  ///Create a widget to show the user that the data is being loaded
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

  ///Create a widget that informs the user that the data was not returned from API.
  // ignore: non_constant_identifier_names
  Widget _APIUnavailableWidget() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("API unavailable. Please try again later.",
              style: TextStyle(fontSize: 15)),
        ]));
  }

  ///A Future to use the first available map app on the current device to show directions
  Future<void> goToGoogleMaps(CarparkInfo info) async {
    final availableMaps = await MapLauncher.installedMaps;
    await availableMaps.first.showDirections(
      destinationTitle: info.address,
      destination: Coords(info.latlng.latitude, info.latlng.longitude),
    );
  }
}
