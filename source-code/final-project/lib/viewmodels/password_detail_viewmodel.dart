import 'package:da_get_it/core/di/service_locator.dart';
import 'package:da_get_it/models/password_model.dart';
import 'package:da_get_it/repositories/password_repository.dart';
import 'package:flutter/foundation.dart';

class PasswordDetailViewModel extends ChangeNotifier {
  final PasswordRepository _passwordRepository;

  PasswordModel? _password;
  PasswordModel? get password => _password;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  String _decryptedPassword = '';
  String get decryptedPassword => _decryptedPassword;

  final int? passwordId;

  PasswordDetailViewModel(this._passwordRepository, this.passwordId) {
    if (passwordId != null) {
      loadPassword(passwordId!);
    }
  }

  /// Load a password by ID
  Future<void> loadPassword(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _password = await _passwordRepository.getPasswordById(id);
      if (_password != null) {
        _decryptedPassword =
            _passwordRepository.decryptPassword(_password!.password);
      }
    } catch (e) {
      debugPrint('Error loading password: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  /// Get a masked password for display
  String getMaskedPassword() {
    return '••••••••••••';
  }

  /// Save password updates
  Future<bool> savePassword(PasswordModel updatedPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _passwordRepository.savePassword(updatedPassword);
      await loadPassword(id);
      return true;
    } catch (e) {
      debugPrint('Error saving password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete the current password
  Future<bool> deletePassword() async {
    if (_password == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _passwordRepository.deletePassword(_password!.id);
      return result;
    } catch (e) {
      debugPrint('Error deleting password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clear sensitive data
    _decryptedPassword = '';
    _password = null;
    super.dispose();
  }
}
