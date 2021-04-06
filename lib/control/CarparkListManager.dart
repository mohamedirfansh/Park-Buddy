import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/control/DistanceFilterManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkCard.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

/// Handles list construction for CarparkListView
class CarparkListManager {
  double _chosenDistance = 0.5;

  CarparkListManager(this._chosenDistance);

  constructList(LocationData currentLocation) {
    final carparks = CarparkInfoManager.filterCarparksByDistance(
        CarparkInfoManager.carparkList,
        _chosenDistance,
        LatLng(currentLocation.latitude, currentLocation.longitude));
    print(_chosenDistance);
    // return ListView.builder(
    //   itemCount: carparks.length,
    //   itemBuilder: (context, index) {
    //     return CarparkCard(carpark: carparks[index]);
    //   },
    // );
    return FutureBuilder(
      future: CarparkAPIInterface.getMultipleCarparkAvailability(
          DateTime.now(), carparks),
      builder: (context, snapshot) {
        if (!snapshot.hasData && !snapshot.hasError) {
          //Loading
          return _loadingWidget(false);
        } else if (snapshot.hasData && snapshot.hasError) {
          return _loadingWidget(true);
        } else if (snapshot.hasData && snapshot.data != null) {
          return _carparkListBuilder(carparks, snapshot.data);
        } else if (snapshot.data == null) {
          return _noCarparkWidget();
        } else {
          //Error
          return Container(child: Text("Error"));
        }
      },
    );
  }

  Widget _carparkListBuilder(List<CarparkInfo> carparks,
      Map<String, CarparkAvailability> carparkAvailMap) {
    return ListView.builder(
        itemCount: carparks.length,
        itemBuilder: (context, index) {
          return CarparkCard(
              carparks[index], carparkAvailMap[carparks[index].carparkCode]);
        });
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

  Widget _noCarparkWidget() {
    return ListView(
      children: [
        Container(
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
        )
      ],
    );
  }
}
