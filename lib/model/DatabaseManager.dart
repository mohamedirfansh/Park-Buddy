import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AvailabilityDatabase.dart';
import 'CarparkAvailability.dart';
import 'CarparkAPIInterface.dart';

class DatabaseManager {

  static HashSet<String> _duplicateSet = HashSet.from([
    "SK24", "STM2", "U11", "SK34", "SK35", "GBM", "KB1", "SB26", "SB27", "SB28", "S28L", "PM13", "Y48", "Y48M", "SB18", "SB21", "Y12", "Y6", "Y34", "Y34A", "Y36",
    "Y40", "Y43", "MPS", "Y10", "Y11", "Y16", "Y18", "Y19", "Y20", "Y21", "Y21M", "Y26", "Y27", "Y28", "Y28M", "Y29", "Y3", "Y33", "Y39", "Y3M", "Y4", "Y41", "Y41M",
    "Y49", "Y49L", "Y49M", "Y5", "Y52M", "Y57", "Y58", "Y62M", "Y63M", "Y64M", "Y65M", "Y66M", "Y68L", "Y68M", "Y7", "Y9", "Y17", "Y31", "Y32", "Y8", "PM41", "PM38",
    "PM35", "PM43", "PM44", "CV1", "CV2", "CV3", "P40L", "PM10", "PM11", "PM12", "PM14", "PM16", "PM17", "PM18", "PM19", "PM20", "PM23", "PM24", "PM25", "PM29", "PM3",
    "PM30", "PM32", "PM33", "PM34", "PM36", "PM37", "PM40", "PM45", "PM6", "PM7", "PM8", "PR1", "PR10", "PR13", "PR14", "PR2", "PR4", "PR7", "PR8", "PM26", "PM46", "S19L", "S24L",
    "SB1", "SB13", "SB16", "SB19", "SB22", "SB23", "SB24", "SB29", "SB3", "SB34", "SB5", "SB6", "SB8", "SB9", "SB30", "SB31", "SB33", "SB11", "S15L",
    "SB12", "SB15", "SB4", "SB7", "SB2", "Y13", "SB10", "Y14", "Y15", "BL8", "BL8L", "MNM", "SK82", "SK84", "TBM2", "H8", "C3M", "ACM", "C24", "C25", "C22M", "GE2"
  ]);


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
    return await _availabilityFromJson(items[0]);
  }

  /// private method to convert retrieved carpark availability json into CarparkAvailability object
  static Future<List<CarparkAvailability>> _availabilityFromJson(Map<String, dynamic> items) async {
    //HashSet<String> duplicateSet = new HashSet<String>();
    var timestamp = items["timestamp"];
    var carparkData = items["carpark_data"];

    var carparkList = List<CarparkAvailability>.from(carparkData.map((x) {
      CarparkAvailability item = CarparkAvailability.fromJson(x, timestamp);
      if (!_duplicateSet.contains(item.carparkNumber)) {
        //duplicateSet.add(item.carparkNumber);
        return item;
      }
    }
    )
    );
    //var count = carparkList.where((c) => c!= null && c.carparkNumber == "STM1").toList().length;
    //print(count);
    await AvailabilityDatabase.instance.batchInsertCarparks(carparkList);
  }
}
// query: https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27

// format: {"carpark_info":[{"total_lots":"91","lot_type":"C","lots_available":"33"}],"carpark_number":"HE12","update_datetime":"2021-03-03T22:49:23"}