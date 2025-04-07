import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'encryption_service.dart';

class AESEncryptionService implements EncryptionService {
  /// Encrypt a password using AES encryption
  @override
  String encryptPassword(String password, String salt) {
    final key = Key.fromUtf8(salt.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return base64Encode(encrypted.bytes);
  }

  /// Decrypt a password using AES encryption
  @override
  String decryptPassword(String encryptedPassword, String salt) {
    final key = Key.fromUtf8(salt.padRight(32, '0').substring(0, 32));
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));

    final encrypted = Encrypted.fromBase64(encryptedPassword);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Generate a random salt for encryption
  @override
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
}
