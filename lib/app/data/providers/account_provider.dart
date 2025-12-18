import 'package:ezmoney/app/data/models/account_model.dart';
import 'package:ezmoney/app/data/providers/db_provider.dart';

class AccountProvider {
  Future<List<Account>> getAllAccounts() async {
    final db = await DatabaseProvider.db.database;
    var res = await db.query("Account");
    List<Account> list = res.isNotEmpty
        ? res.map((c) => Account.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> addAccount(Account account) async {
    final db = await DatabaseProvider.db.database;
    var raw = await db.insert("Account", account.toJson());
    return raw;
  }

  Future<int> updateAccount(Account account) async {
    final db = await DatabaseProvider.db.database;
    var res = await db.update(
      "Account",
      account.toJson(),
      where: "id = ?",
      whereArgs: [account.id],
    );
    return res;
  }

  Future<int> deleteAccount(int id) async {
    final db = await DatabaseProvider.db.database;
    return await db.delete("Account", where: "id = ?", whereArgs: [id]);
  }
}
