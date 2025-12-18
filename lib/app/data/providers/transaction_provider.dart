import 'package:ezmoney/app/data/models/transaction_model.dart';
import 'package:ezmoney/app/data/providers/db_provider.dart';

class TransactionProvider {
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await DatabaseProvider.db.database;
    var res = await db.query(
      "Transaction",
      orderBy: "date DESC, created_at DESC",
    );
    List<TransactionModel> list = res.isNotEmpty
        ? res.map((c) => TransactionModel.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await DatabaseProvider.db.database;
    var raw = await db.insert("Transaction", transaction.toJson());
    return raw;
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await DatabaseProvider.db.database;
    var res = await db.update(
      "Transaction",
      transaction.toJson(),
      where: "id = ?",
      whereArgs: [transaction.id],
    );
    return res;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await DatabaseProvider.db.database;
    return await db.delete("Transaction", where: "id = ?", whereArgs: [id]);
  }
}
