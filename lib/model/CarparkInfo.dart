import 'dart:core';
import 'package:geodesy/geodesy.dart';
import 'package:park_buddy/model/CarparkPaymentMethod.dart';
import 'package:park_buddy/model/CarparkType.dart';
import 'package:park_buddy/model/ShortTermParkingAvailability.dart';

class CarparkInfo {
  CarparkInfo(
    this.carparkCode,
    this.address,
    this.latlng,
    this.carparkType,
    this.carparkPaymentMethod,
    this.shortTermParking,
  );

  final String carparkCode;
  final String address;
  final LatLng latlng;
  final CarparkType carparkType;
  final CarparkPaymentMethod carparkPaymentMethod;
  final ShortTermParkingAvailability shortTermParking;
}

class CarparkAvailabilityInfo {
  CarparkAvailabilityInfo(this.carparkCode, this.totalLots, this.availableLots);
  final String carparkCode;
  final num totalLots;
  num availableLots;
}
