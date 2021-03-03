import 'dart:convert';
import 'package:dio/dio.dart';

class DatabaseManager {
  static Future<List<Carpark>> getAllEmployees() async {
    var url = "https://api.data.gov.sg/v1/transport/carpark-availability";
    Response response = await Dio().get(url);

    return employeeFromJson((response.data as List)[0]);
  }
}

List<Carpark> employeeFromJson(String str) {
  List<dynamic> jsonList = json.decode(json.decode(str).sublist(1)); // carpark_data list
  return List<Carpark>.from(jsonList.map((x) => Carpark.fromJson(x,jsonList[0])));
}

//String employeeToJson(List<Carpark> data) =>
  //  json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Carpark {
  String carparkID;
  int totalLots;
  String lotType;
  int lotsAvailable;
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

  factory Carpark.fromJson(Map<String, dynamic> json, String timestamp) => Carpark(
    timestamp: timestamp,
    carparkNumber: json["carpark_number"],
    totalLots: json["carpark_info"]["total_lots"],
    lotType: json["carpark_info"]["lot_type"],
    lotsAvailable: json["carpark_info"]["lots_available"],
    updateDatetime: json["update_datetime"],
  );
}
