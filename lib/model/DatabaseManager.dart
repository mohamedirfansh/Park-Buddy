import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AvailabilityDatabase.dart';
import 'CarparkAvailability.dart';
import 'CarparkAPIInterface.dart';

class DatabaseManager {
  /**
  static Future<List<CarparkAvailability>> pullCarparkAvailability() async {
    var url = "https://api.data.gov.sg/v1/transport/carpark-availability";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      final items = list['items'];
      return _availabilityFromJson(items[0]); //response.data as List
    } else {
      throw Exception("Failed to connect to server");
    }
    */
  static Future pullCarparkAvailability(DateTime date) async {
    String availJson = await CarparkAPIInterface.getCarparkJson(date);
    final list = json.decode(availJson);
    final items = list['items'];
    return _availabilityFromJson(items[0]);
  }
}

/// private method to convert retrieved carpark availability json into CarparkAvailability object
List<CarparkAvailability> _availabilityFromJson(Map<String, dynamic> items) {
  var timestamp = items["timestamp"];
  var carparkData = items["carpark_data"];

  return List<CarparkAvailability>.from(carparkData.map((x) {
      CarparkAvailability item = CarparkAvailability.fromJson(x, timestamp);
      AvailabilityDatabase.instance.insertCarpark(item); //
      return item;
      }
    )
  );
}
// query: https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27

// format: {"carpark_info":[{"total_lots":"91","lot_type":"C","lots_available":"33"}],"carpark_number":"HE12","update_datetime":"2021-03-03T22:49:23"}