import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:flutter/foundation.dart';

class PasswordListViewModel extends ChangeNotifier {
  final PasswordRepository _passwordRepository;

  List<PasswordModel> _passwords = [];
  List<PasswordModel> get passwords => _passwords;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PasswordListViewModel(this._passwordRepository) {
    loadPasswords();
  }

  /// Load all passwords
  Future<void> loadPasswords() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedCategory.isNotEmpty) {
        _passwords =
            await _passwordRepository.getPasswordsByCategory(_selectedCategory);
      } else if (_searchQuery.isNotEmpty) {
        _passwords = await _passwordRepository.searchPasswords(_searchQuery);
      } else {
        _passwords = await _passwordRepository.getAllPasswords();
      }
    } catch (e) {
      debugPrint('Error loading passwords: $e');
      _passwords = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter passwords by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _searchQuery = '';
    await loadPasswords();
  }

  /// Search passwords
  Future<void> searchPasswords(String query) async {
    _searchQuery = query;
    _selectedCategory = '';
    await loadPasswords();
  }

  /// Delete a password
  Future<bool> deletePassword(int id) async {
    final result = await _passwordRepository.deletePassword(id);
    if (result) {
      await loadPasswords();
    }
    return result;
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _selectedCategory = '';
    _searchQuery = '';
    await loadPasswords();
  }

  /// Decrypt a password for display
  String decryptPassword(String encryptedPassword) {
    try {
      return _passwordRepository.decryptPassword(encryptedPassword);
    } catch (e) {
      debugPrint('Error decrypting password: $e');
      return '***';
    }
  }
}
