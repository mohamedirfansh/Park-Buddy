import 'dart:collection';
import 'package:sqflite/sqflite.dart';

import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/AvailabilityDatabase.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';

class DatabaseManager {
  static final _table = "AvailabilityTable";

  /// Pull Carpark Availability API an convert into CarparkAvailability objects.
  static Future<List<Map>> pullCarparkAvailability(DateTime date,
      {bool insertIntoDatabase = false}) async {
    var items = await CarparkAPIInterface.getCarparkMap(date);
    return await _availabilityFromJson(items, insertIntoDatabase);
  }

  /// private method to convert retrieved carpark availability json into CarparkAvailability object
  static Future<List<Map>> _availabilityFromJson(
      Map<String, dynamic> items, bool insertIntoDatabase) async {
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
          carparkList.removeWhere((c) =>
              c.carparkNumber ==
              item.carparkNumber); // remove the older carparkavailability
          carparkList.add(item);
          duplicateSet[item.carparkNumber] =
              item.updateDatetime; // update duplicateSet
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
  static Future<int> updateCarpark(
      CarparkAvailability carparkAvailability) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    Map<String, dynamic> row = carparkAvailability.toMap();
    var carparkNumber = row['carparkNumber'];
    var timestamp = row['timestamp'];
    var query = await dbClient.update(_table, row,
        where: 'carparkNumber = ? AND timestamp = ?',
        whereArgs: [carparkNumber, timestamp]);
    return query;
  }

  /// Delete a specific carpark availability record
  static Future<int> deleteCarpark(
      String carparkNumber, DateTime timestamp) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timestamp.millisecondsSinceEpoch;
    var query = await dbClient.delete(_table,
        where: 'carparkNumber = ? AND timestamp = ?',
        whereArgs: [carparkNumber, time]);
    return query;
  }

  /// Delete one carpark's availability information before a given datetime
  static Future<int> deleteCarparkBefore(
      String carparkNumber, DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(_table,
        where: 'carparkNumber = ? AND timestamp < ?',
        whereArgs: [carparkNumber, time]);
    return query;
  }

  /// Delete all carpark's availability information before a given datetime
  static Future<int> deleteAllCarparkBefore(DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient
        .delete(_table, where: 'timestamp < ?', whereArgs: [time]);
    return query;
  }

  // Return a list of all Carparks, sorted by date
  static Future<Map> getCarparkList(String carparkNumber) async {
    final dbClient = await AvailabilityDatabase.instance.database;
    List<Map> results = await dbClient.query(
      _table,
      columns: CarparkAvailability.columns,
      where: 'carparkNumber = ?',
      whereArgs: [carparkNumber],
      orderBy: 'timestamp ASC',
    );
    List<CarparkAvailability> convertedResult = [];
    results.forEach((element) {
      CarparkAvailability carpark = CarparkAvailability(
          carparkNumber: element['carparkNumber'],
          timestamp: element['timestamp'],
          updateDatetime: element['updateDatetime'],
          singleType: element['singleType'],
          totalLotsH: element['totalLotsH'],
          totalLotsC: element['totalLotsC'],
          totalLotsY: element['totalLotsY'],
          lotsAvailableH: element['lotsAvailableH'],
          lotsAvailableC: element['lotsAvailableC'],
          lotsAvailableY: element['lotsAvailableY']
      );
      convertedResult.add(carpark);
    });


    Map<String, List> dayMap = {
      'Mon': [],
      'Tues': [],
      'Wed': [],
      'Thurs': [],
      'Fri': [],
      'Sat': [],
      'Sun': [],
    };


    convertedResult.forEach((element) {
      DateTime entryDate = DateTime.fromMillisecondsSinceEpoch(element.timestamp);
      switch (entryDate.weekday) {
        case 1:
          dayMap['Mon'].add(element);
          break;
        case 2:
          dayMap['Tues'].add(element);
          break;
        case 3:
          dayMap['Wed'].add(element);
          break;
        case 4:
          dayMap['Thurs'].add(element);
          break;
        case 5:
          dayMap['Fri'].add(element);
          break;
        case 6:
          dayMap['Sat'].add(element);
          break;
        case 7:
          dayMap['Sun'].add(element);
          break;
      }
    });
    dayMap.forEach((key, value) {
      value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
    return dayMap;
  }

  static void printAllCarparks() async {
    final dbClient = await AvailabilityDatabase.instance.database;
    List<Map> results =
        await dbClient.query(_table, columns: CarparkAvailability.columns);

    results.forEach((result) {
      print(result);
    });
    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $_table'));
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

  static Future checkWindow(DateTime start, DateTime end) async {
    int startEpoch = start.millisecondsSinceEpoch;
    int endEpoch = end.millisecondsSinceEpoch;
    final dbClient = await AvailabilityDatabase.instance.database;

    var count = await dbClient.rawQuery(
        'SELECT COUNT(*) FROM $_table WHERE timestamp >= $startEpoch AND timestamp <= $endEpoch');
    print(Sqflite.firstIntValue(count));
  }
}

// query: https://api.data.gov.sg/v1/transport/carpark-availability?date_time=2020-03-05T01%3A40%3A27

// format: {"carpark_info":[{"total_lots":"91","lot_type":"C","lots_available":"33"}],"carpark_number":"HE12","update_datetime":"2021-03-03T22:49:23"}
// other format: {"carpark_info":[{"total_lots":"73","lot_type":"C","lots_available":"0"},{"total_lots":"12","lot_type":"Y","lots_available":"2"},
//                {"total_lots":"50","lot_type":"H","lots_available":"50"}],"carpark_number":"K2T","update_datetime":"2021-03-11T20:19:17"}
// "carpark_number":"SK24","update_datetime":"2021-03-11T20:30:08"},{"carpark_info":[{"total_lots":"181","lot_type":"Y","lots_available":"200"}],"carpark_number":"SK24","update_datetime":"2016-02-19T11:19:28"},{"carpark_info":[{"total_lots":"181","lot_type":"H","lots_available":"200"}],"carpark_number":"SK24","update_datetime":"2016-02-19T11:19:29"},{"carpark_info":[{"total_lots":"225","lot_type":"C","lots_available":"61"}]
