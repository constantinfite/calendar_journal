import 'package:calendar_journal/repositories/database_connection.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  DataBaseConnection? _dataBaseConnection;

  Repository() {
    //Initialize database  connection
    _dataBaseConnection = DataBaseConnection();
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _dataBaseConnection?.setDatabaseCalendar();
    return _database!;
  }

  insertData(table, data) async {
    var connection = await database;
    return await connection.insert(table, data);
  }

  //Read data from Table
  readData(table) async {
    var connection = await database;
    return await connection.query(
      table,
    );
  }

  readEvents(table, research, List<String> categories) async {
    var connection = await database;
    if (categories.isNotEmpty) {
      String categoriesJoin =
          categories.map((category) => "'$category'").join(", ");
      // ignore: prefer_interpolation_to_compose_strings
      return await connection.rawQuery("SELECT * FROM " +
          table +
          " WHERE name LIKE '%" +
          research +
          "%' and category IN (" +
          categoriesJoin +
          ") ORDER BY datetime DESC");
    } else {
      String categoriesJoin = "SELECT name FROM categories";
      // ignore: prefer_interpolation_to_compose_strings
      return await connection.rawQuery("SELECT * FROM " +
          table +
          " WHERE name LIKE '%" +
          research +
          "%' and category IN (" +
          categoriesJoin +
          ") ORDER BY datetime DESC");
    }
  }

  //Read data from Table by Id
  readDataById(table, itemId) async {
    var connection = await database;
    return await connection.query(table, where: 'id=?', whereArgs: [itemId]);
  }

  updateData(table, data) async {
    var connection = await database;
    return await connection
        .update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  // Delete data from table
  deleteData(table, itemId) async {
    var connection = await database;
    return await connection.rawDelete("DELETE FROM $table WHERE id = $itemId");
  }
}
