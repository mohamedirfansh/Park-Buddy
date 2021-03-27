import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:location/location.dart';
import 'package:park_buddy/boundary/CarparkAPIInterface.dart';

import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkCard.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

/// Handles list construction for CarparkListView
class CarparkListManager {
  constructList(LatLng center, LocationData currentLocation) {
      final carparks = CarparkInfoManager.filterCarparksByDistance(
          CarparkInfoManager.carparkList,
          0.5,
          LatLng(center.latitude, center.longitude));

      // return ListView.builder(
      //   itemCount: carparks.length,
      //   itemBuilder: (context, index) {
      //     return CarparkCard(carpark: carparks[index]);
      //   },
      // );
      return FutureBuilder(
        future: CarparkAPIInterface.getMultipleCarparkAvailability(DateTime.now(), carparks),
        builder: (context, snapshot) {
        if (snapshot.hasData == false && !snapshot.hasError) {
          //Loading
          return Container(child: Text("Loading"));
        } else if (snapshot.hasData) {
          return _carparkListBuilder(carparks, snapshot.data);
        } else {
          //Error
          return Container(child: Text("Error"));
        }
      },
      );
  }

  Widget _carparkListBuilder(List<CarparkInfo> carparks, Map<String, CarparkAvailability> carparkAvailMap) {
    return ListView.builder(
          itemCount: carparks.length,
          itemBuilder: (context, index) {
            return CarparkCard(carparks[index], carparkAvailMap[carparks[index].carparkCode]);
          },
        );
  }
}