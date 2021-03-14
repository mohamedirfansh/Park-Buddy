import 'dart:collection';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'AvailabilityDatabase.dart';
import 'CarparkAvailability.dart';
import 'CarparkAPIInterface.dart';

class DatabaseManager {
  static final table = "AvailabilityTable";
  /*
  static HashSet<String> _duplicateSet = HashSet.from([
    "SK24", "STM2", "U11", "SK34", "SK35", "GBM", "KB1", "SB26", "SB27", "SB28", "S28L", "PM13", "Y48", "Y48M", "SB18", "SB21", "Y12", "Y6", "Y34", "Y34A", "Y36",
    "Y40", "Y43", "MPS", "Y10", "Y11", "Y16", "Y18", "Y19", "Y20", "Y21", "Y21M", "Y26", "Y27", "Y28", "Y28M", "Y29", "Y3", "Y33", "Y39", "Y3M", "Y4", "Y41", "Y41M",
    "Y49", "Y49L", "Y49M", "Y5", "Y52M", "Y57", "Y58", "Y62M", "Y63M", "Y64M", "Y65M", "Y66M", "Y68L", "Y68M", "Y7", "Y9", "Y17", "Y31", "Y32", "Y8", "PM41", "PM38",
    "PM35", "PM43", "PM44", "CV1", "CV2", "CV3", "P40L", "PM10", "PM11", "PM12", "PM14", "PM16", "PM17", "PM18", "PM19", "PM20", "PM23", "PM24", "PM25", "PM29", "PM3",
    "PM30", "PM32", "PM33", "PM34", "PM36", "PM37", "PM40", "PM45", "PM6", "PM7", "PM8", "PR1", "PR10", "PR13", "PR14", "PR2", "PR4", "PR7", "PR8", "PM26", "PM46", "S19L", "S24L",
    "SB1", "SB13", "SB16", "SB19", "SB22", "SB23", "SB24", "SB29", "SB3", "SB34", "SB5", "SB6", "SB8", "SB9", "SB30", "SB31", "SB33", "SB11", "S15L",
    "SB12", "SB15", "SB4", "SB7", "SB2", "Y13", "SB10", "Y14", "Y15", "BL8", "BL8L", "MNM", "SK82", "SK84", "TBM2", "H8", "C3M", "ACM", "C24", "C25", "C22M", "GE2"
  ]);
*/
  static Future pullCarparkAvailability(DateTime date) async {
    final items = await CarparkAPIInterface.getCarparkMap(date);
    await _availabilityFromJson(items);
  }

  /// private method to convert retrieved carpark availability json into CarparkAvailability object
  static Future _availabilityFromJson(Map<String, dynamic> items) async {
    var carparkList = createCarparkAvailabilityListFromMap(items);
    await batchInsertCarparks(carparkList);
  }

  static List<CarparkAvailability> createCarparkAvailabilityListFromMap(Map<String, dynamic> items){
    HashSet<String> duplicateSet = new HashSet<String>();
    var timestamp = items["timestamp"];
    var carparkData = items["carpark_data"];

    var carparkList = List<CarparkAvailability>.from(carparkData.map((x) {
      CarparkAvailability item = CarparkAvailability.fromJson(x, timestamp);
      if (!duplicateSet.contains(item.carparkNumber)) {
        duplicateSet.add(item.carparkNumber);
        return item;
      }
    }));
    return carparkList;
  }
  /// insert a new CarparkAvailability object into the table
  static Future insertCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var query = await dbClient.insert(table, carparkAvailability.toMap());
    return query;
  }
  /// Note: ID and timestamp must match to update a row.
  // TODO: better way to query? timestamp must be exact to find the carpark.
  static Future<int> updateCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    Map<String, dynamic> row = carparkAvailability.toMap();
    var carparkNumber = row['carparkNumber'];
    var timestamp = row['timestamp'];
    var query = await dbClient.update(
        table,
        row,
        where: 'carparkNumber = ? AND timestamp = ?', whereArgs: [carparkNumber, timestamp]);
    return query;
  }

  /// Delete one carpark's availability information before a given datetime
  static Future<int> deleteCarparkBefore(String carparkNumber, DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(
        table,
        where: 'carparkNumber = ? AND timestamp < ?',
        whereArgs: [carparkNumber, time]
    );
    return query;
  }

  /// Delete all carpark's availability information before a given datetime
  static Future<int> deleteAllCarparkBefore(DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(
        table,
        where: 'timestamp < ?',
        whereArgs: [time]
    );
    return query;
  }

  static void printAllCarparks() async {
    final db = await AvailabilityDatabase.instance.database;
    List<Map>
    results = await db.query(table, columns: CarparkAvailability.columns);

    List<CarparkAvailability> list = new List();
    if (list.length == 0) print("empty");
    results.forEach((result) {
      print(result);
    });
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
    print(count);
  }

  static Future batchInsertCarparks(List<CarparkAvailability> carparks) async {
    final db = await AvailabilityDatabase.instance.database;
    final batch = db.batch();
    /// Batch insert
    for (var i = 0; i < carparks.length; i++) {
      if (carparks[i] != null) {
        batch.insert(table, carparks[i].toMap());
      }
    }
    await batch.commit(noResult: true);
  }
}

// query: https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27

// format: {"carpark_info":[{"total_lots":"91","lot_type":"C","lots_available":"33"}],"carpark_number":"HE12","update_datetime":"2021-03-03T22:49:23"}
// other format: {"carpark_info":[{"total_lots":"73","lot_type":"C","lots_available":"0"},{"total_lots":"12","lot_type":"Y","lots_available":"2"},
//                {"total_lots":"50","lot_type":"H","lots_available":"50"}],"carpark_number":"K2T","update_datetime":"2021-03-11T20:19:17"}
// "carpark_number":"SK24","update_datetime":"2021-03-11T20:30:08"},{"carpark_info":[{"total_lots":"181","lot_type":"Y","lots_available":"200"}],"carpark_number":"SK24","update_datetime":"2016-02-19T11:19:28"},{"carpark_info":[{"total_lots":"181","lot_type":"H","lots_available":"200"}],"carpark_number":"SK24","update_datetime":"2016-02-19T11:19:29"},{"carpark_info":[{"total_lots":"225","lot_type":"C","lots_available":"61"}]