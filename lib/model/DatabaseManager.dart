import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseManager {
  static Future<List<Carpark>> getAllEmployees() async {
    var url = "https://api.data.gov.sg/v1/transport/carpark-availability";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final list = json.decode(response.body);
      final items = list['items'];

      return employeeFromJson(items[0]); //response.data as List
    } else {
      throw Exception("Failed to connect to server");
    }
  }
}

List<Carpark> employeeFromJson(Map<String, dynamic> items) {
  var timestamp = items["timestamp"];
  var carparkData = items["carpark_data"];

  return List<Carpark>.from(carparkData.map((x) => Carpark.fromJson(x, timestamp)));
}

class Carpark {
  var totalLots;
  String lotType;
  var lotsAvailable;
  String carparkNumber;
  String updateDatetime;
  String timestamp;

  Carpark({
    this.carparkNumber,
    this.totalLots,
    this.lotType,
    this.lotsAvailable,
    this.updateDatetime,
    this.timestamp,
});

  factory Carpark.fromJson(Map<String, dynamic> json, String timestamp) {
    var carparkInfo = json["carpark_info"][0];
    return Carpark(
      timestamp: timestamp,
      carparkNumber: json["carpark_number"],
      totalLots: int.parse(carparkInfo["total_lots"]),
      lotType: carparkInfo["lot_type"],
      lotsAvailable: int.parse(carparkInfo["lots_available"]),
      updateDatetime: json["update_datetime"],
    );
  }
}

// format: {"carpark_info":[{"total_lots":"91","lot_type":"C","lots_available":"33"}],"carpark_number":"HE12","update_datetime":"2021-03-03T22:49:23"}