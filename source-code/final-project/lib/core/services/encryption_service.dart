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

  /// Encrypt a password and return the encrypted password with salt
  /// Returns a string in the format "encryptedPassword:salt"
  String encryptPassword(String password);

  /// Decrypt a password using the same XOR cipher
  String decryptPassword(String encryptedPassword);

  /// Generate a random salt for encryption
  String generateSalt();
}

enum EncryptionType {
  AES,
  RSA,
}
