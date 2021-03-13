import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
}