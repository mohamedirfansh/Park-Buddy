import 'package:intl/intl.dart';

class CarparkAvailability {
  int totalLots;
  String lotType;
  int lotsAvailable;
  String carparkNumber;
  int updateDatetime;
  int timestamp;
  static final columns = ["carparkNumber", "timestamp", "updateDatetime", "lotType", "totalLots", "lotsAvailable"];

  CarparkAvailability({
    this.carparkNumber,
    this.totalLots,
    this.lotType,
    this.lotsAvailable,
    this.updateDatetime,
    this.timestamp,
  });
  /// factory method to parse from json map
  factory CarparkAvailability.fromJson(Map<String, dynamic> json, String timestamp) {
    final dateFormat = DateFormat('yyyy-MM-ddThh:mm:ss');
    var carparkInfo = json["carpark_info"][0];
    return CarparkAvailability(
      timestamp: dateFormat.parse(timestamp).millisecondsSinceEpoch,
      carparkNumber: json["carpark_number"],
      totalLots: int.parse(carparkInfo["total_lots"]),
      lotType: carparkInfo["lot_type"],
      lotsAvailable: int.parse(carparkInfo["lots_available"]),
      updateDatetime: dateFormat.parse(json["update_datetime"]).millisecondsSinceEpoch,
    );
  }
  /// Converts object to a map for storage into database
  Map<String, dynamic> toMap() {
    return {
      'carparkNumber': carparkNumber,
      'totalLots': totalLots,
      'lotType': lotType,
      'lotsAvailable': lotsAvailable,
      'updateDateTime': updateDatetime,
      'timestamp': timestamp,
    };
  }
}