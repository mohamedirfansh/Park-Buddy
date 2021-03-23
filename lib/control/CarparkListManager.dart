import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';

import 'package:park_buddy/control/CarparkInfoManager.dart';
import 'package:park_buddy/entity/CarparkCard.dart';

/// Handles list construction for CarparkListView
class CarparkListManager {
  constructList(LatLng center, Position currentLocation) {
    if (center != null) {
      final carparks = CarparkInfoManager.filterCarparksByDistance(
          CarparkInfoManager.carparkList,
          0.5,
          LatLng(center.latitude, center.longitude));

      return ListView.builder(
        itemCount: carparks.length,
        itemBuilder: (context, index) {
          return CarparkCard(carpark: carparks[index]);
        },
      );
    }
  }
}