import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'encryption_service.dart';

class AESEncryptionService implements EncryptionService {
  /// Encrypt a password using AES encryption
  @override
  String encryptPassword(String password) {
    final salt = _generateSalt();
    final key = Key.fromUtf8(salt);
    final encrypter = Encrypter(AES(key));

    final iv = IV.allZerosOfLength(16);
    final encrypted = encrypter.encrypt(password, iv: iv);
    final encryptedPassword = base64Encode(encrypted.bytes);

    return "$encryptedPassword:$salt";
  }

  /// Decrypt a password using AES encryption
  @override
  String decryptPassword(String encryptedPassword) {
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted password format');
    }

    final encrypted = parts[0];
    final salt = parts[1];
    final key = Key.fromUtf8(salt);
    final encrypter = Encrypter(AES(key));

    final encryptedData = Encrypted.fromBase64(encrypted);
    final iv = IV.allZerosOfLength(16);
    return encrypter.decrypt(encryptedData, iv: iv);
  }

  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
}
