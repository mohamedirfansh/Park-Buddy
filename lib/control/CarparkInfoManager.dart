import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';

import 'package:park_buddy/entity/CarparkInfo.dart';
import 'package:park_buddy/entity/CarparkPaymentMethod.dart';
import 'package:park_buddy/entity/CarparkType.dart';
import 'package:park_buddy/entity/ShortTermParkingAvailability.dart';

///This class is responsible for providing CarparkInfo data, loaded from the CSV obtained from the Singapore government.
///This data is static information about the carparks like their addresses, LatLng info and unique carpark codes.
class CarparkInfoManager {
  static List<CarparkInfo> _carparkList = [];

  static List<CarparkInfo> get carparkList {
    return _carparkList;
  }

  ///Loads the data into memory from our internal CSV file and caches it.
  static Future<List> loadDataFromCSV() async {
    final carparkData = await rootBundle.loadString(
        'assets/hdb-carpark-information-latlng-fixed.csv',
        cache: true);
    if (carparkData.isEmpty) {
      throw Exception('No csv found');
    }

    ///Gets the CSV format and applies it across each line.
    const d = const FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    List<List<dynamic>> res =
        const CsvToListConverter(csvSettingsDetector: d).convert(carparkData);

    for (var i = 1; i < res.length; i++) {
      CarparkType carparkType;
      switch (res[i][4]) {
        case 'BASEMENT CAR PARK':
          carparkType = CarparkType.basement;
          break;
        case 'MULTI-STOREY CAR PARK':
          carparkType = CarparkType.multistorey;
          break;
        case 'SURFACE CAR PARK':
          carparkType = CarparkType.surface;
          break;
        case 'MECHANISED CAR PARK':
          carparkType = CarparkType.mechanised;
          break;
        case 'COVERED CAR PARK':
          carparkType = CarparkType.covered;
          break;
        case 'MECHANISED AND SURFACE CAR PARK':
          carparkType = CarparkType.mechanisedAndSurface;
          break;
        case 'SURFACE/MULTI-STOREY CAR PARK':
          carparkType = CarparkType.multistoreyAndSurface;
          break;
      }

      CarparkPaymentMethod paymentMethod;
      switch (res[i][5]) {
        case 'ELECTRONIC PARKING':
          paymentMethod = CarparkPaymentMethod.electronicParking;
          break;
        case 'COUPON PARKING':
          paymentMethod = CarparkPaymentMethod.couponParking;
          break;
      }

      ShortTermParkingAvailability shortTermParkingAvailability;
      switch (res[i][6]) {
        case 'WHOLE DAY':
          shortTermParkingAvailability = ShortTermParkingAvailability.wholeDay;
          break;
        case '7AM-7PM':
          shortTermParkingAvailability =
              ShortTermParkingAvailability.morning7am_7pm;
          break;
        case '7AM-10.30PM':
          shortTermParkingAvailability =
              ShortTermParkingAvailability.morning7am_1030pm;
          break;
        case 'NO':
          shortTermParkingAvailability =
              ShortTermParkingAvailability.unavailable;
          break;
      }
      if (shortTermParkingAvailability == null) {
        throw Exception('Unknown availability found.');
      }

      ///Creates a CarparkInfo object from the line and adds it to the carparkList.
      var carparkInfo = CarparkInfo(
        res[i][0],
        res[i][1],
        LatLng(double.parse(res[i][2].toString()),
            double.parse(res[i][3].toString())),
        carparkType,
        paymentMethod,
        shortTermParkingAvailability,
      );
      carparkList.add(carparkInfo);
    }
    return carparkList;
  }

  /// Filters the master carparkList by distance from the given position and returns a filtered list
  static List<CarparkInfo> filterCarparksByDistance(
      num limitInKM, LatLng currentPos) {
    Geodesy geodesy = Geodesy();
    if (carparkList.length == null) {
      throw Exception('Carpark list empty.');
    }
    return carparkList
        .where((carpark) =>
            geodesy.distanceBetweenTwoGeoPoints(carpark.latlng, currentPos) <
            limitInKM * 1000)
        .toList();
  }
}