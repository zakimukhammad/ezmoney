import 'package:ezmoney/app/data/models/category_model.dart';
import 'package:ezmoney/app/data/providers/db_provider.dart';

class CategoryProvider {
  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseProvider.db.database;
    var res = await db.query("Category");
    List<Category> list = res.isNotEmpty
        ? res.map((c) => Category.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    final db = await DatabaseProvider.db.database;
    var res = await db.query("Category", where: "type = ?", whereArgs: [type]);
    List<Category> list = res.isNotEmpty
        ? res.map((c) => Category.fromJson(c)).toList()
        : [];
    return list;
  }

  Future<int> addCategory(Category category) async {
    final db = await DatabaseProvider.db.database;
    var raw = await db.insert("Category", category.toJson());
    return raw;
  }

  Future<int> updateCategory(Category category) async {
    final db = await DatabaseProvider.db.database;
    var res = await db.update(
      "Category",
      category.toJson(),
      where: "id = ?",
      whereArgs: [category.id],
    );
    return res;
  }

  Future<int> deleteCategory(int id) async {
    final db = await DatabaseProvider.db.database;
    return await db.delete("Category", where: "id = ?", whereArgs: [id]);
  }
}
