//query format: 2021-03-05T01:40:27 --> https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

class CarparkAPIInterface {
  static final dateFormat = DateFormat('yyyy-MM-ddThh%3Amm%3Ass');
  static final jsonDateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  /// Pull HDB carpark availability data for a specified date and time
  static Future<Map> getCarparkMap(DateTime dateTime) async {
    String d = dateFormat.format(dateTime);
    var url =
        "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      final items = list['items'][0];
      return items;
    } else {
      throw Exception("Failed to retrieve Carpark API data");
    }
  }

  static Future<CarparkAvailability> getSingleCarparkAvailability(
      DateTime dateTime, CarparkInfo carpark) async {
    String d = dateFormat.format(dateTime);
    var url =
        "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      final info = list['items'][0]['carpark_data']
          .where((item) => (item["carpark_number"] == carpark.carparkCode))
          .toList();
      if (info.length > 1) {
        print("duplicate found");
      } else if (info.length < 1) {
        throw Exception("Failed to retrieve Carpark API data");
      }
      return CarparkAvailability.createFromJson(info.elementAt(0), dateTime);
    } else {
      print("error fetching api");
      throw Exception("Failed to retrieve Carpark API data");
    }
  }
}
