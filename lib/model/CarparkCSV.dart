import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/services.dart';
import 'package:geodesy/geodesy.dart';
import 'package:park_buddy/model/CarparkInfo.dart';
import 'package:park_buddy/model/CarparkPaymentMethod.dart';
import 'package:park_buddy/model/CarparkType.dart';
import 'package:park_buddy/model/ShortTermParkingAvailability.dart';

class CarParkCSV {
  static List<CarparkInfo> carparkList = List<CarparkInfo>();

  static Future<List> loadData() async {

    final carparkData = await rootBundle
        .loadString('assets/hdb-carpark-information-latlng.csv', cache: true);
    if (carparkData.isEmpty) {
      throw Exception('No csv found');
    }

    //final res = const CsvToListConverter().convert(carparkData);
    const d = const FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n']);
    List<List<dynamic>> res = const CsvToListConverter(csvSettingsDetector: d).convert(carparkData);

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
    int num = carparkList.length;
    return carparkList;
  }

  static List<CarparkInfo> dataFilteredByDistance(
      List<CarparkInfo> dataList, num limitInKM, LatLng currentPos) {
    Geodesy geodesy = Geodesy();
    if (dataList.length == null) {
      throw Exception('Carpark list empty.');
    }
    return dataList
        .where((carpark) =>
            geodesy.distanceBetweenTwoGeoPoints(carpark.latlng, currentPos) <
            limitInKM * 1000)
        .toList();
  }

  // void _convertXYtoLatLngFromCSV async() {
  //   final coords = [];
  //   final XYvals = [];
  //   final res = const CsvToListConverter().convert(carparkData);
  //   res.sublist(1).forEach((carpark) => XYvals.add([double.parse(carpark[2]), double.parse(carpark[3])]));
  //
  //
  //   for (var i = 0; i < XYvals.length; i++) {
  //     try {
  //       var converted = await convertXYToLatLng(XYvals[i][0], XYvals[i][1]);
  //       coords.add([converted.lat, converted.lng]);
  //       sleep(Duration(milliseconds: 250));
  //     } catch(e) {
  //       print(e);
  //       print('Index $i failed to convert. Carpark name: ${res[i + 1][0]}');
  //     }
  //
  //
  //
  //   }
  //
  //
  //   for (var i = 1; i < res.length; i++){
  //     res[i][2] = coords[i-1][0];
  //     res[i][3] = coords[i-1][1];
  //   }
  //   try {
  //     String csv = const ListToCsvConverter().convert(res);
  //     final directory = await getApplicationDocumentsDirectory();
  //     print(directory.path);
  //     final path = directory.path;
  //     final file = File('$path/hdb-carpark-information-latlng.csv');
  //     await file.writeAsString(csv);
  //   } catch(e) {
  //     print(e);
  //     print('Unable to write CSV');
  //   }
  // }

}
