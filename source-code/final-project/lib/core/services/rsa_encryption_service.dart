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
  String encryptPassword(String password, String salt) {
    final encrypter = Encrypter(RSA(publicKey: _keypair.publicKey));
    final encrypted = encrypter.encrypt(password);
    return base64Encode(encrypted.bytes);
  }

  /// Decrypt a password using RSA encryption
  @override
  String decryptPassword(String encryptedPassword, String salt) {
    final encrypter = Encrypter(RSA(privateKey: _keypair.privateKey));
    final encrypted = Encrypted.fromBase64(encryptedPassword);
    return encrypter.decrypt(encrypted);
  }

  /// Generate a random salt for encryption
  @override
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
}
