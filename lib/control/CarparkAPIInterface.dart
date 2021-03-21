//query format: 2021-03-05T01:40:27 --> https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

/// Boundary class for interfacing between external HDB Carpark Availability API and ParkBuddy application
/// @category Boundary)
class CarparkAPIInterface {
  /// Date format of API
  static final dateFormat = DateFormat('yyyy-MM-ddTHH%3Amm%3Ass');

  /// Pull HDB carpark availability data for a specified date and time
  static Future<String> getCarparkJson(DateTime dateTime) async{
    String d = dateFormat.format(dateTime);
    var url = "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to connect to Carpark API");
    }
  }
}