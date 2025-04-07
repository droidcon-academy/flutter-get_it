import 'package:da_get_it/core/services/aes_encryption_service.dart';
import 'package:da_get_it/core/services/rsa_encryption_service.dart';

export 'aes_encryption_service.dart';
export 'rsa_encryption_service.dart';

abstract class EncryptionService {
  static EncryptionService createAES() {
    return AESEncryptionService();
  }

  static EncryptionService createRSA() {
    return RSAEncryptionService();
  }

  /// Encrypt a password with a simple XOR cipher
  /// Note: This is a simplified encryption for demonstration purposes
  /// In a real app, use a stronger encryption method
  String encryptPassword(String password, String salt);

  /// Decrypt a password using the same XOR cipher
  String decryptPassword(String encryptedPassword, String salt);

  /// Generate a random salt for encryption
  String generateSalt();
}

enum EncryptionType {
  AES,
  RSA,
}
