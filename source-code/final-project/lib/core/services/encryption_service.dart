import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class EncryptionService {
  /// Encrypt a password with a simple XOR cipher
  /// Note: This is a simplified encryption for demonstration purposes
  /// In a real app, use a stronger encryption method
  String encryptPassword(String password, String salt) {
    final List<int> passwordBytes = utf8.encode(password);
    final List<int> saltBytes = utf8.encode(salt);
    
    // Create a key from the salt using SHA-256
    final key = sha256.convert(saltBytes).bytes;
    
    // XOR the password bytes with the key
    final List<int> encryptedBytes = List<int>.filled(passwordBytes.length, 0);
    
    for (int i = 0; i < passwordBytes.length; i++) {
      encryptedBytes[i] = passwordBytes[i] ^ key[i % key.length];
    }
    
    return base64Encode(encryptedBytes);
  }
  
  /// Decrypt a password using the same XOR cipher
  String decryptPassword(String encryptedPassword, String salt) {
    final List<int> encryptedBytes = base64Decode(encryptedPassword);
    final List<int> saltBytes = utf8.encode(salt);
    
    // Create the same key from the salt
    final key = sha256.convert(saltBytes).bytes;
    
    // XOR the encrypted bytes with the key to get the original password
    final List<int> passwordBytes = List<int>.filled(encryptedBytes.length, 0);
    
    for (int i = 0; i < encryptedBytes.length; i++) {
      passwordBytes[i] = encryptedBytes[i] ^ key[i % key.length];
    }
    
    return utf8.decode(passwordBytes);
  }
  
  /// Generate a random salt for encryption
  String generateSalt() {
    final random = Random.secure();
    final List<int> saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
} 