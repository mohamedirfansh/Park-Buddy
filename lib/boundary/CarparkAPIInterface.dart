//query format: 2021-03-05T01:40:27 --> https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:park_buddy/entity/CarparkInfo.dart';

/// This class provides static methods to access carpark availability information from the API.
/// {@category Boundary}
class CarparkAPIInterface {
  static final dateFormat = DateFormat('yyyy-MM-ddTHH%3Amm%3Ass');
  static final jsonDateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');

  /// Pull HDB carpark availability data for a specified date and time.
  ///
  /// This functions takes a requested [dateTime] and queries the government API for data.
  /// This returns the full list of un-parsed carpark availability information.
  /// The API does not support individual carpark retrieval.
  static Future<Map> getCarparkMap(DateTime dateTime) async {
    String d = dateFormat.format(dateTime);
    var url =
        "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      final items = list['items'][0];
      return items;
    } else if (response.statusCode == 400) { // bad response (when testing)
      throw BadRequestException();
    } else {
      throw Exception("Failed to retrieve Carpark API data");
    }
  }

  /// Returns a single carpark for a specified time and carpark
  ///
  /// Takes a requested [dateTime] and [carpark] info, queries the government API and returns a single carpark.
  /// Used in the CarparkInfoPage when we need to show only a single carpark's up-to-date information.
  static Future<CarparkAvailability> getSingleCarparkAvailability(
      DateTime dateTime, CarparkInfo carpark) async {
    String d = dateFormat.format(dateTime);
    var url =
        "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(Uri.parse(url));
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
      print(response.statusCode);
      print(response.body);
      throw Exception("Failed to retrieve Carpark API data");
    }
  }

  /// Returns a list of carparks for a specified time and list of carparks
  ///
  /// Takes requested [dateTime] and [carparks] to query the government API and returns a list of carpark information.
  /// Used in the CarparkListView when we show multiple carpark information.
  static Future<Map<String, CarparkAvailability>> getMultipleCarparkAvailability(
      DateTime dateTime, List<CarparkInfo> carparks) async {
    String d = dateFormat.format(dateTime);
    var url =
        "https://api.data.gov.sg/v1/transport/carpark-availability?date_time=$d";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {

      final rawCarparkData = json.decode(
          response.body)['items'][0]['carpark_data'];
      final carparkCodeList = [];
      carparks.forEach((element) => carparkCodeList.add(element.carparkCode));
      final carparkList = rawCarparkData
          .where((item) => (carparkCodeList.contains(item["carpark_number"])))
          .toList();

      final Map<String, CarparkAvailability> carparkAvailabilityMap = Map<String, CarparkAvailability>();

      carparkList.forEach((carpark) => carparkAvailabilityMap[carpark["carpark_number"]] = CarparkAvailability.createFromJson(carpark, dateTime));
      return carparkAvailabilityMap;
    } else {
      throw Exception("Failed to retrieve Carpark API data");
    }
  }
}

/// Exception to describe bad requests from API and combines the error code and message.
class BadRequestException implements Exception {
  final _message;
  final _prefix;

  BadRequestException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}
