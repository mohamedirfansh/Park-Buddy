import 'package:intl/intl.dart';
/// Stores a carpark's availability information at a given time.
/// (@category Entity)
class CarparkAvailability {
  /// Total number of lots of type H
  int totalLotsH;
  /// Total number of lots of type C
  int totalLotsC;
  /// Total number of lots of type Y
  int totalLotsY;
  /// Indicates if carpark has only 1 lot type available
  int singleType; // 1: carpark only has one lot type available. 0: carpark has multiple types available.
  /// Available number of lots of type H
  int lotsAvailableH;
  /// Available number of lots of type C
  int lotsAvailableC;
  /// Available number of lots of type Y
  int lotsAvailableY;
  /// The identification number of the carpark
  String carparkNumber;
  /// Time the carpark's availability information was updated in the API
  int updateDatetime;
  /// Time the carpark availability information was pulled from the API
  int timestamp;

  static final columns = ['carparkNumber',
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
    this.lotsAvailableH,
    this.lotsAvailableC,
    this.lotsAvailableY,
    this.updateDatetime,
    this.timestamp,
  });
  /// factory method to create a CarparkAvailability object from a json mapping
  factory CarparkAvailability.fromJson(Map<String, dynamic> json, String timestamp) {
    final dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
    DateTime date = dateFormat.parse(timestamp);
    int totalH=0, totalC=0, totalY=0;
    int availH=0, availC=0, availY=0;

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
      timestamp: date.millisecondsSinceEpoch,
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