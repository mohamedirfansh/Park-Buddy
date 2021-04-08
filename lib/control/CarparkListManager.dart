import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:park_buddy/boundary/CarparkAPIInterface.dart';

import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkCard.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

/// Handles list construction for CarparkListView
class CarparkListManager {

  ///Handles the building logic for getting a list of carparks and their availability.
  ///
  /// The FutureBuilder returns a widget based on the Future, as we are asynchronously getting data from the API.
  ///
  /// If the Future has no data to return yet, we show a loading Widget.
  ///
  /// If the Future has data but contains an error, we show the error Widget.
  ///
  /// If the Future has non-null data, we use the data to construct the carpark list.
  /// If that list is null, we return a widget telling the user that there are no carparks nearby.
  ///
  /// Finally, as a fallback, we return a Container showing an error.
  Widget constructList(LocationData currentLocation) {
      final carparks = CarparkInfoManager.filterCarparksByDistance(
          0.5,
          LatLng(currentLocation.latitude, currentLocation.longitude));
      return FutureBuilder(
        future: CarparkAPIInterface.getMultipleCarparkAvailability(DateTime.now(), carparks),
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return _loadingWidget();
          } else if (snapshot.hasData && snapshot.hasError) {
            return _APIErrorWidget();
          } else if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.isEmpty){
              return _noCarparkWidget();
            } else return _carparkListBuilder(carparks, snapshot.data);
          } else {
            return Container(child: Center(child: Text("Error")));
          }
        },
      );
  }

  ///Returns a ListViewBuilder that takes a list and dynamically fills a ListView with CarparkCards. These are UI objects that encapsulates the Carpark information.
  ///
  /// @param carparks The list of fixed carpark information
  /// @param carparkAvailMap The raw data of carparkAvailability
  ///
  /// @see CarparkCard
  Widget _carparkListBuilder(List<CarparkInfo> carparks, Map<String, CarparkAvailability> carparkAvailMap) {
    return ListView.builder(
          itemCount: carparks.length,
          itemBuilder: (context, index) {
            return CarparkCard(carparks[index], carparkAvailMap[carparks[index].carparkCode]);
          }
        );
  }

  ///The widget to show when the API is still loading. Shows a spinning loading ring.
  Widget _loadingWidget() {
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

  ///The widget to show when the API returns an error. This could be due to government API maintenance or other problems outside of the app.
  // ignore: non_constant_identifier_names
  Widget _APIErrorWidget() {
    return ListView(
      children: [Container(
      height: 100,
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: AssetImage('assets/images/parking-icon.png'),
          ),
          title: Text("API unavailable, try again later"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Invalid carpark list, please check internet connection",
                style: TextStyle(fontSize: 15.0),
              ),
              Text(
                "Carpark list status: unavailable",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    )],
    );
  }

  ///The widget to show when there are no carparks in the vicinity. Gives the users a hint to search in another area.
  Widget _noCarparkWidget() {
    return ListView(
      children: [Container(
        height: 100,
        padding: EdgeInsets.only(top: 8.0),
        child: Card(
          elevation: 2,
          margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25.0,
              backgroundImage: AssetImage('assets/images/parking-icon.png'),
            ),
            title: Text("No carparks in area."),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Try searching another area.",
                  style: TextStyle(fontSize: 15.0),
                ),
                Text(
                  "No carparks available in your vicinity.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      )],
    );
  }

}