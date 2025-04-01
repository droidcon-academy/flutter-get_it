import 'package:da_get_it/models/category_model.dart';
import 'package:da_get_it/repositories/category_repository.dart';
import 'package:flutter/foundation.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CategoryViewModel(this._categoryRepository) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getAllCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveCategory(CategoryModel category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _categoryRepository.saveCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      debugPrint('Error saving category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _categoryRepository.deleteCategory(id);
      if (result) {
        await loadCategories();
      }
      return result;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> getCategoryByName(String name) async {
    try {
      return await _categoryRepository.getCategoryByName(name);
    } catch (e) {
      debugPrint('Error getting category by name: $e');
      return null;
    }
  }
}
