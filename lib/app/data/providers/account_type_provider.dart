import 'package:sqflite/sqflite.dart';
import '../models/account_type_model.dart';
import 'db_provider.dart';

class AccountTypeProvider {
  Future<Database> get database async => await DatabaseProvider.db.database;

  Future<List<AccountType>> getAllAccountTypes() async {
    final db = await database;
    var res = await db.query("AccountType");
    List<AccountType> list = res.isNotEmpty
        ? res.map((c) => AccountType.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> addAccountType(AccountType type) async {
    final db = await database;
    return await db.insert("AccountType", type.toJson());
  }

  Future<int> updateAccountType(AccountType type) async {
    final db = await database;
    return await db.update(
      "AccountType",
      type.toJson(),
      where: "id = ?",
      whereArgs: [type.id],
    );
  }

  Future<int> deleteAccountType(int id) async {
    final db = await database;
    return await db.delete("AccountType", where: "id = ?", whereArgs: [id]);
  }
}
