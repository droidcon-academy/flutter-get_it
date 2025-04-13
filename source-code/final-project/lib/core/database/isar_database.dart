import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/models/category_model.dart';
import 'initial_data.dart';

class IsarDatabase {
  Isar db;

  IsarDatabase(this.db);

  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await Isar.open(
      [PasswordModelSchema, CategoryModelSchema],
      directory: dir.path,
    );
    await initCategories(db);
    return db;
  }

  Future<void> closeDb() async {
    await db.close();
  }

  Future<List<PasswordModel>> getAllPasswords() async {
    return await db.passwordModels.where().findAll();
  }

  Future<PasswordModel?> getPasswordById(int id) async {
    return await db.passwordModels.get(id);
  }

  Future<int> savePassword(PasswordModel password) async {
    return await db.writeTxn(() async {
      await db.passwordModels.put(password);
      return password.id;
    });
  }

  Future<bool> deletePassword(int id) async {
    return await db.writeTxn(() async {
      return await db.passwordModels.delete(id);
    });
  }

  Future<List<CategoryModel>> getAllCategories() async {
    return await db.categoryModels.where().findAll();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    return await db.categoryModels.get(id);
  }

  Future<int> saveCategory(CategoryModel category) async {
    return await db.writeTxn(() async {
      await db.categoryModels.put(category);
      return category.id;
    });
  }

  Future<bool> deleteCategory(int id) async {
    return await db.writeTxn(() async {
      return await db.categoryModels.delete(id);
    });
  }
}
