import 'package:da_get_it/core/services/aes_encryption_service.dart';
import 'package:da_get_it/core/services/rsa_encryption_service.dart';

export 'aes_encryption_service.dart';
export 'rsa_encryption_service.dart';

abstract class EncryptionService {
  static EncryptionService createAES() => AESEncryptionService();

  static EncryptionService createRSA() => RSAEncryptionService();

  String encryptPassword(String password);

  String decryptPassword(String encryptedPassword);
}

enum EncryptionType {
  AES,
  RSA,
}
