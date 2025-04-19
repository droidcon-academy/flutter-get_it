import 'package:da_get_it/core/database/isar_database.dart';
import 'package:da_get_it/models/category_model.dart';

class CategoryRepository {
  final IsarDatabase _database;

  CategoryRepository(this._database);

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    return await _database.getAllCategories();
  }

  /// Get a category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    return await _database.getCategoryById(id);
  }

  /// Get a category by name
  Future<CategoryModel?> getCategoryByName(String name) async {
    final allCategories = await _database.getAllCategories();
    final matchingCategories =
        allCategories.where((category) => category.name == name).toList();
    return matchingCategories.isNotEmpty ? matchingCategories.first : null;
  }

  /// Save a category (creates or updates)
  Future<int> saveCategory(CategoryModel category) async {
    return await _database.saveCategory(category);
  }

  /// Delete a category
  Future<bool> deleteCategory(int id) async {
    return await _database.deleteCategory(id);
  }
}
