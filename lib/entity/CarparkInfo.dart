import 'dart:core';
import 'package:geodesy/geodesy.dart';
import 'package:park_buddy/entity/CarparkPaymentMethod.dart';
import 'package:park_buddy/entity/CarparkType.dart';
import 'package:park_buddy/entity/ShortTermParkingAvailability.dart';

///This entity class holds static information about a carpark.
class CarparkInfo {
  CarparkInfo(
    this._carparkCode,
    this._address,
    this._latlng,
    this._carparkType,
    this._carparkPaymentMethod,
    this._shortTermParking,
  );

  final String _carparkCode;
  final String _address;
  final LatLng _latlng;
  final CarparkType _carparkType;
  final CarparkPaymentMethod _carparkPaymentMethod;
  final ShortTermParkingAvailability _shortTermParking;

  String get carparkCode {
    return _carparkCode;
  }

  LatLng get latlng {
    return _latlng;
  }

  String get address {
    return _address;
  }

  CarparkType get carparkType {
    return _carparkType;
  }

  CarparkPaymentMethod get carparkPaymentMethod {
    return _carparkPaymentMethod;
  }

  ShortTermParkingAvailability get shortTermParking {
    return _shortTermParking;
  }
}