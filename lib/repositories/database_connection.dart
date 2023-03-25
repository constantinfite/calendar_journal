import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseConnection {
  setDatabaseCategory() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_categorylist_sqflite');
    Directory? externalStoragePath = await getExternalStorageDirectory();
    String dataBasePath = await getDatabasesPath();
    print(dataBasePath);
    print(externalStoragePath);
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDatabaseCategory);
    return database;
  }

  _onCreatingDatabaseCategory(Database database, int version) async {
    await database.execute(
        "CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT, color INTEGER, emoji TEXT)");
  }

  setDatabaseEvent() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_eventlist_sqflite');
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDatabaseEvent);
    return database;
  }

  _onCreatingDatabaseEvent(Database database, int version) async {
    await database.execute(
        "CREATE TABLE events(id INTEGER PRIMARY KEY, name TEXT, datetime INTEGER, description TEXT, category TEXT, score INTEGER)");
  }
}
