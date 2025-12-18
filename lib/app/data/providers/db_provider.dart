import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider db = DatabaseProvider._();
  DatabaseProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "EzMoney.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE Account ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "type TEXT,"
          "icon INTEGER,"
          "color INTEGER,"
          "balance REAL"
          ")",
        );

        await db.execute(
          "CREATE TABLE Category ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "type TEXT,"
          "icon INTEGER,"
          "color INTEGER"
          ")",
        );

        await db.execute(
          "CREATE TABLE 'Transaction' ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "account_id INTEGER,"
          "category_id INTEGER,"
          "transfer_account_id INTEGER,"
          "amount REAL,"
          "date TEXT,"
          "note TEXT,"
          "type TEXT,"
          "created_at TEXT"
          ")",
        );
      },
    );
  }
}
