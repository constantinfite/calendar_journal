import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DataBaseConnection {

  setDatabaseCalendar() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'calendar.db');
    var database = await openDatabase(path,
        version: 1, onCreate: _onCreatingDataBaseCalendar);
    return database;
  }

  _onCreatingDataBaseCalendar(Database database, int version) async {
    await database.execute(
        "CREATE TABLE events(id INTEGER PRIMARY KEY, name TEXT, datetime INTEGER, description TEXT, category TEXT, score INTEGER, FOREIGN KEY (category) REFERENCES categories(name))"
        "CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT, color INTEGER, emoji TEXT)");
  }
}
