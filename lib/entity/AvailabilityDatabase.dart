import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

/// SQLite database to store historical carpark lot availability data.
/// (@category Entity)
/// (@subCategory Persistent Data)
class AvailabilityDatabase {
  AvailabilityDatabase._(); // ensure only one copy of database exists
  /// Instance of AvailabilityDatabase to prevent multiple copies of database in memory
  static final AvailabilityDatabase instance = new AvailabilityDatabase._();

  /// Name of table within database
  static final _table = "AvailabilityTable";

  /// Singleton instance of database
  static Database _database;

  /// Lazy initialization method
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initializeDB();
    return _database;
  }

  /// When the app first launches, this will load the database from memory.
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
  /// Primary Key: (carparkNumber, timestamp), example: (HE11, DateTime..millisecondsSinceEpoch)
  Future _createTable(Database dbClient, int ver) async {
    await dbClient.execute("""
    CREATE TABLE $_table(
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