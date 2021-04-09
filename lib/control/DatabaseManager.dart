import 'dart:collection';
import 'package:semaphore/semaphore.dart';
import 'package:sqflite/sqflite.dart';

import 'package:park_buddy/boundary/CarparkAPIInterface.dart';
import 'package:park_buddy/entity/AvailabilityDatabase.dart';
import 'package:park_buddy/entity/CarparkAvailability.dart';

///The class to interface with the device's local SQL database.
class DatabaseManager {
  static final _table = "AvailabilityTable";
  static final _sm = LocalSemaphore(10);

  /// Pull Carpark Availability API and convert into CarparkAvailability objects.
  static Future<List<Map>> pullCarparkAvailability(DateTime date,
      {bool insertIntoDatabase = false}) async {
    try {
      var items = await CarparkAPIInterface.getCarparkMap(date);
      return await _availabilityFromJson(items, insertIntoDatabase);
    } catch(e) {
      print("cannot connect");
    }
  }

  /// Private method to convert retrieved carpark availability json into CarparkAvailability objects
  /// @param items The JSON map retrieved from the API representing the carpark availability information
  /// @param insertIntoDatabase The option to update the database with the information retrieved from the API.
  static Future<List<Map>> _availabilityFromJson(
      Map<String, dynamic> items, bool insertIntoDatabase) async {
    Map<String, int> duplicateSet = new HashMap<String, int>();
    var timestamp = items["timestamp"];
    var carparkData = items["carpark_data"];

    List<CarparkAvailability> carparkList = [];
    List<Map<String, dynamic>> returnList = [];
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

  /// insert a new CarparkAvailability object into the database
  static Future insertCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var query = await dbClient.insert(_table, carparkAvailability.toMap());
    return query;
  }
  /// Update method for a carpark.
  /// 
  /// Note: ID and timestamp must match to update a row.
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

  /// Delete one carpark's availability information before a given datetime. Used when the carpark availability information is out of date and needs to be synchronised again.
  static Future<int> deleteCarparkBefore(
      String carparkNumber, DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(_table,
        where: 'carparkNumber = ? AND timestamp < ?',
        whereArgs: [carparkNumber, time]);
    return query;
  }

  /// Delete all carpark's availability information before a given datetime. Used when all carpark availability information is out of date and needs to be synchronised again.
  static Future<int> deleteAllCarparkBefore(DateTime timeBefore) async {
    var dbClient = await AvailabilityDatabase.instance.database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(_table, where: 'timestamp < ?', whereArgs: [time]);
    return query;
  }

  /// Return a map of all CarparkAvailability, with the weekday as a key to access the day's list of CarparkAvailability.
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

    //Bucket the list into each day
    Map<String, List> dayMap = {
      'Mon': [],
      'Tues': [],
      'Wed': [],
      'Thurs': [],
      'Fri': [],
      'Sat': [],
      'Sun': [],
    };

    //Sort the list to the map
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
    
    //Sort the days by their timestamp
    dayMap.forEach((key, value) {
      value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
    
    return dayMap;
  }

  ///Debugging method to print all carparks.
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

  ///Get a count of all entries in a table. Used for debugging.
  static Future<int> getCountOfEntries() async {
    final dbClient = await AvailabilityDatabase.instance.database;

    int count = Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $_table'));
    (count > 0) ? print(count) : print("empty");
    return count;
  }

  ///Insert carparks into database as a batch. Uses a semaphore to prevent concurrent insertion from multiple sources.
  static int count = 0;
  static Future batchInsertCarparks(List<CarparkAvailability> carparks) async {
    final dbClient = await AvailabilityDatabase.instance.database;
    final batch = dbClient.batch();
    /// Batch insert
    for (var i = 0; i < carparks.length; i++) {
      if (carparks[i] != null) {
        batch.insert(_table, carparks[i].toMap());
      }
    }
    try {
      await _sm.acquire();
      await batch.commit(noResult: true);
      print("commited $count");
      count++;
    } finally {
      _sm.release();
    }
  }

  ///Debugging method to check the entries within a specific time window.
  static Future checkWindow(DateTime start, DateTime end) async {
    int startEpoch = start.millisecondsSinceEpoch;
    int endEpoch = end.millisecondsSinceEpoch;
    final dbClient = await AvailabilityDatabase.instance.database;

    var count = await dbClient.rawQuery(
        'SELECT COUNT(*) FROM $_table WHERE timestamp >= $startEpoch AND timestamp <= $endEpoch');
    print(Sqflite.firstIntValue(count));
  }
}