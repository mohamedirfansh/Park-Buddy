import 'dart:async';
import 'dart:io';
import 'package:park_buddy/model/DatabaseManager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'CarparkAvailability.dart';

class AvailabilityDatabase {
  AvailabilityDatabase._(); // ensure only one copy of database exists
  static final AvailabilityDatabase instance = new AvailabilityDatabase._();
  static final table = "AvailabilityTable";

  static Database _database;
  /// Lazy initialization method
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initializeDB();
    return _database;
  }

  Future<Database> initializeDB() async {
    Directory d = await getApplicationDocumentsDirectory();
    String path = d.path + 'availabilityDB.db';
    var db = await openDatabase(
        path,
        version:1,
        onOpen: (db) {},
        onCreate: _createTable
    );
    return db;
  }

  /// Create a table to store carpark availability data
  ///
  /// Primary Key: (carparkNumber, timestamp), example: (HE11, DateTime..millisecondsSinceEpoch)
  Future _createTable(Database dbClient, int ver) async {
    await dbClient.execute("""
    CREATE TABLE $table(
      carparkNumber TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      updateDatetime INTEGER,
      singleType INTEGER,
      totalLotsH INTEGER,
      totalLotsC INTEGER,
      totalLotsY INTEGER,
      lotsAvailableH INTEGER,
      lotsAvailableC INTEGER,
      lotsAvailableY INTEGER,
      PRIMARY KEY (carparkNumber, timestamp));""");
  }

  /// insert a new CarparkAvailability object into the table
  Future insertCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await database;
    var query = await dbClient.insert(table, carparkAvailability.toMap());
    return query;
  }
  /// Note: ID and timestamp must match to update a row.
  // TODO: better way to query? timestamp must be exact to find the carpark.
  Future<int> updateCarpark(CarparkAvailability carparkAvailability) async {
    var dbClient = await database;
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
  Future<int> deleteCarparkBefore(String carparkNumber, DateTime timeBefore) async {
    var dbClient = await database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(
      table,
      where: 'carparkNumber = ? AND timestamp < ?',
      whereArgs: [carparkNumber, time]
    );
  }

  /// Delete all carpark's availability information before a given datetime
  Future<int> deleteAllCarparkBefore(DateTime timeBefore) async {
    var dbClient = await database;
    var time = timeBefore.millisecondsSinceEpoch;
    var query = await dbClient.delete(
        table,
        where: 'timestamp < ?',
        whereArgs: [time]
    );
  }

  void getAllCarparks() async {
    final db = await database;
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

  Future batchInsertCarparks(List<CarparkAvailability> carparks) async {
    final db = await database;
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