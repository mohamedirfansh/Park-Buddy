import 'package:intl/intl.dart';

class CarparkAvailability {
  int totalLotsH;
  int totalLotsC;
  int totalLotsY;
  int singleType; // 1: carpark only has one lot type available. 0: carpark has multiple types available.
  int lotsAvailableH;
  int lotsAvailableC;
  int lotsAvailableY;
  String carparkNumber;
  int updateDatetime;
  int timestamp;
  static final columns = ["carparkNumber",
    'timestamp',
    'updateDatetime',
    'singleType',
    'totalLotsH',
    'totalLotsC',
    'totalLotsY',
    'lotsAvailableH',
    'lotsAvailableC',
    'lotsAvailableY'];

  CarparkAvailability({
    this.carparkNumber,
    this.singleType,
    this.totalLotsH,
    this.totalLotsC,
    this.totalLotsY,
    //this.lotType,
    this.lotsAvailableH,
    this.lotsAvailableC,
    this.lotsAvailableY,
    this.updateDatetime,
    this.timestamp,
  });
  /// factory method to parse from json map
  factory CarparkAvailability.fromJson(Map<String, dynamic> json, String timestamp) {
    final dateFormat = DateFormat('yyyy-MM-ddThh:mm:ss');
    int totalH=0, totalC=0, totalY=0;
    int availH=0, availC=0, availY=0;
    //var carparkInfo = json["carpark_info"][0];
    int numCarparkTypes = json["carpark_info"].length;
    for (int i=0; i<json["carpark_info"].length; i++) {
      var currentLotInfo = json["carpark_info"][i];
      String type = currentLotInfo["lot_type"];
      switch (type) {
        case "H":
          totalH = int.parse(currentLotInfo["total_lots"]);
          availH = int.parse(currentLotInfo["lots_available"]);
          break;
        case "C":
          totalC = int.parse(currentLotInfo["total_lots"]);
          availC = int.parse(currentLotInfo["lots_available"]);
          break;
        case "Y":
          totalY = int.parse(currentLotInfo["total_lots"]);
          availY = int.parse(currentLotInfo["lots_available"]);
          break;
      }
    }
    return CarparkAvailability(
      timestamp: dateFormat.parse(timestamp).millisecondsSinceEpoch,
      carparkNumber: json["carpark_number"],
      singleType: (numCarparkTypes == 1) ? 1 : 0,
      totalLotsH: totalH,
      totalLotsC: totalC,
      totalLotsY: totalY,
      lotsAvailableH: availH,
      lotsAvailableC: availC,
      lotsAvailableY: availY,
      updateDatetime: dateFormat.parse(json["update_datetime"]).millisecondsSinceEpoch,
    );
  }
  /// Converts object to a map for storage into database
  Map<String, dynamic> toMap() {
    return {
      'carparkNumber': carparkNumber,
      'singleType': singleType,
      'totalLotsH': totalLotsH,
      'totalLotsC': totalLotsC,
      'totalLotsY': totalLotsY,
      'lotsAvailableH': lotsAvailableH,
      'lotsAvailableC': lotsAvailableC,
      'lotsAvailableY': lotsAvailableY,
      'updateDateTime': updateDatetime,
      'timestamp': timestamp,
    };
  }
}