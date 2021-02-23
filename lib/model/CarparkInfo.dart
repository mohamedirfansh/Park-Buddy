import 'package:test_app/model/CarparkPaymentMethod.dart';
import 'package:test_app/model/CarparkType.dart';
import 'package:test_app/model/ShortTermParkingAvailability.dart';

class CarparkInfo {
  CarparkInfo(
      this.carparkCode,
      this.address,
      this.lat,
      this.lng,
      this.carparkType,
      this.carparkPaymentMethod,
      this.shortTermParking
      );

  final String carparkCode;
  final String address;
  final double lat;
  final double lng;
  final CarparkType carparkType;
  final CarparkPaymentMethod carparkPaymentMethod;
  final ShortTermParkingAvailability shortTermParking;
}