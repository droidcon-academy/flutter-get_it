import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'encryption_service.dart';

class RSAEncryptionService implements EncryptionService {
  late RSA _keypair;

  RSAEncryptionService() {
    _keypair = RSA();
  }

  /// Encrypt a password using RSA encryption
  @override
  String encryptPassword(String password) {
    final salt = generateSalt();
    final encrypter = Encrypter(RSA(publicKey: _keypair.publicKey));
    final encrypted = encrypter.encrypt(password);
    final encryptedPassword = base64Encode(encrypted.bytes);
    return "$encryptedPassword:$salt";
  }

  /// Decrypt a password using RSA encryption
  @override
  String decryptPassword(String encryptedPassword) {
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted password format');
    }

    final encrypted = parts[0];
    final encrypter = Encrypter(RSA(privateKey: _keypair.privateKey));
    final encryptedData = Encrypted.fromBase64(encrypted);
    return encrypter.decrypt(encryptedData);
  }

  /// Generate a random salt for encryption
  @override
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
}
