import 'dart:collection';
import 'dart:convert';
import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/AvailabilityDatabase.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';
import 'package:sqflite/sqflite.dart';

import 'PullDateManager.dart';

class DatabaseManager {
  static final _table = "AvailabilityTable";

  /// Pull Carpark Availability API an convert into CarparkAvailability objects.
  static Future<List<Map>> pullCarparkAvailability(DateTime date, {bool insertIntoDatabase=false}) async {
    String availJson = await CarparkAPIInterface.getCarparkJson(date);
    final list = json.decode(availJson);
    final items = list['items'];
    return await _availabilityFromJson(items[0], insertIntoDatabase);
  }

  /// private method to convert retrieved carpark availability json into CarparkAvailability object
  static Future<List<Map>> _availabilityFromJson(Map<String, dynamic> items, bool insertIntoDatabase) async {
    Map<String, int> duplicateSet = new HashMap<String, int>();
    var timestamp = items["timestamp"];
    var carparkData = items["carpark_data"];

    var carparkList = List<CarparkAvailability>();
    List returnList = List<Map<String, dynamic>>();
    for (var x in carparkData) {
      CarparkAvailability item = CarparkAvailability.fromJson(x, timestamp);
      if (!duplicateSet.containsKey(item.carparkNumber)) {
        duplicateSet[item.carparkNumber] = item.updateDatetime;
        carparkList.add(item);
      } else {
        if (item.updateDatetime > duplicateSet[item.carparkNumber]) {
          carparkList.removeWhere((c) => c.carparkNumber == item.carparkNumber); // remove the older carparkavailability
          carparkList.add(item);
          duplicateSet[item.carparkNumber] = item.updateDatetime; // update duplicateSet
        }
      }
    }
    if (insertIntoDatabase)
      await batchInsertCarparks(carparkList);
    else {
      carparkList.forEach((x) => returnList.add(x.toMap()));
      return returnList;
    }
  }
  /// insert a new CarparkAvailability object into the table
  static Future insertCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var query = await dbClient.insert(_table, carparkAvailability.toMap());
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
        _table,
        row,
        where: 'carparkNumber = ? AND timestamp = ?', whereArgs: [carparkNumber, timestamp]);
    return query;
  }

  /// Delete a specific carpark availability record
  static Future<int> deleteCarpark(String carparkNumber, DateTime timestamp) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timestamp.millisecondsSinceEpoch;
    var query = await dbClient.delete(
        _table,
        where: 'carparkNumber = ? AND timestamp = ?',
        whereArgs: [carparkNumber, time]
    );
    return query;
  }

  /// Delete one carpark's availability information before a given datetime
  static Future<int> deleteCarparkBefore(String carparkNumber, DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(
        _table,
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
        _table,
        where: 'timestamp < ?',
        whereArgs: [time]
    );
    PullDateManager.saveDate(0); // reset last pull date if deletion from database is done.
    return query;
  }

  // Return a list of all Carparks, sorted by date
  static Future<List<Map>> getCarparkList(String carparkNumber) async {
    final dbClient = await AvailabilityDatabase.instance.database;
    List<Map> results = await dbClient.query(
        _table,
        columns: CarparkAvailability.columns,
        where: 'carparkNumber = ?',
        whereArgs: [carparkNumber],
        orderBy: 'timestamp ASC',
    );
    return results;
  }

  static void printAllCarparks() async {
    final dbClient = await AvailabilityDatabase.instance.database;
    List<Map> results = await dbClient.query(_table, columns: CarparkAvailability.columns);

    results.forEach((result) {
      print(result);
    });
    int count = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $_table'));
    (count > 0) ? print(count) : print("empty");
  }

  static Future batchInsertCarparks(List<CarparkAvailability> carparks) async {
    final dbClient = await AvailabilityDatabase.instance.database;
    final batch = dbClient.batch();
    /// Batch insert
    for (var i = 0; i < carparks.length; i++) {
      if (carparks[i] != null) {
        batch.insert(_table, carparks[i].toMap());
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