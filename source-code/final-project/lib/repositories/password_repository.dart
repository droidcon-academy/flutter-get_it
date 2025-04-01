import 'package:da_get_it/core/database/isar_database.dart';
import 'package:da_get_it/core/services/encryption_service.dart';
import 'package:da_get_it/models/password_model.dart';

class PasswordRepository {
  final IsarDatabase _database;
  final EncryptionService _encryptionService;

  PasswordRepository(this._database, this._encryptionService);
  
  /// Get all passwords
  Future<List<PasswordModel>> getAllPasswords() async {
    return await _database.getAllPasswords();
  }
  
  /// Get passwords by category
  Future<List<PasswordModel>> getPasswordsByCategory(String category) async {
    final allPasswords = await _database.getAllPasswords();
    return allPasswords.where((password) => password.category == category).toList();
  }
  
  /// Get a password by ID
  Future<PasswordModel?> getPasswordById(int id) async {
    return await _database.getPasswordById(id);
  }
  
  /// Save a password (creates or updates)
  Future<int> savePassword(PasswordModel password) async {
    // Encrypt the password before saving
    final salt = _encryptionService.generateSalt();
    final encryptedPassword = _encryptionService.encryptPassword(password.password, salt);
    
    // Update the password field with the encrypted value
    password.password = "$encryptedPassword:$salt";
    
    return await _database.savePassword(password);
  }
  
  /// Delete a password
  Future<bool> deletePassword(int id) async {
    return await _database.deletePassword(id);
  }
  
  /// Search passwords by title or username
  Future<List<PasswordModel>> searchPasswords(String query) async {
    final allPasswords = await _database.getAllPasswords();
    return allPasswords.where((password) => 
      password.title.toLowerCase().contains(query.toLowerCase()) || 
      password.username.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  /// Decrypt a stored password
  String decryptPassword(String encryptedPassword) {
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted password format');
    }
    
    final encrypted = parts[0];
    final salt = parts[1];
    
    return _encryptionService.decryptPassword(encrypted, salt);
  }
} 