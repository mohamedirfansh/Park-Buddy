import 'dart:core';
import 'package:geodesy/geodesy.dart';
import 'package:test_app/model/CarparkPaymentMethod.dart';
import 'package:test_app/model/CarparkType.dart';
import 'package:test_app/model/ShortTermParkingAvailability.dart';

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