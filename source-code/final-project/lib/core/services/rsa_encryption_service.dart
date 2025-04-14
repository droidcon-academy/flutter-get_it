import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:da_get_it/core/services/encryption_service.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
// Key storage constants
const String _privateKeyTag = 'rsa_private_key';
const String _publicKeyTag = 'rsa_public_key';
// Key size (2048 bits is considered secure)
const int _keySize = 2048;

class RSAEncryptionService implements EncryptionService {
  // Flutter secure storage for storing keys
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _keyPair;
  RSAEncryptionService() {
    _getKeyPair().then((value) => _keyPair = value);
  }

  @override
  String encryptPassword(String password) {
    final publicKey = _keyPair.publicKey;

    final cipher = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    // RSA can only encrypt limited amount of data, so we'll use UTF-8 encoding
    final dataToEncrypt = Uint8List.fromList(utf8.encode(password));

    // Make sure password isn't too long for RSA encryption
    if (dataToEncrypt.length > (_keySize ~/ 8) - 42) {
      throw Exception(
          'Password too long for RSA encryption with this key size');
    }

    final encryptedData = cipher.process(dataToEncrypt);

    // Return as base64 string for easy storage
    return base64.encode(encryptedData);
  }

  @override
  String decryptPassword(String encryptedPassword) {
    final privateKey = _keyPair.privateKey;

    final cipher = RSAEngine()
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    // Decode base64 encrypted data
    final encryptedData = base64.decode(encryptedPassword);

    final decryptedData = cipher.process(Uint8List.fromList(encryptedData));

    // Return as UTF-8 string
    return utf8.decode(decryptedData);
  }
}

// Generate RSA key pair and store them securely
Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> _getKeyPair() async {
  // Check if keys already exist
  final existingPublicKey = await _secureStorage.read(key: _publicKeyTag);
  final existingPrivateKey = await _secureStorage.read(key: _privateKeyTag);

  if (existingPublicKey != null && existingPrivateKey != null) {
    // Parse existing keys
    final publicKey = RSAPublicKey(
        BigInt.parse(json.decode(existingPublicKey)['modulus']),
        BigInt.parse(json.decode(existingPublicKey)['exponent']));

    final privateKey = RSAPrivateKey(
        BigInt.parse(json.decode(existingPrivateKey)['modulus']),
        BigInt.parse(json.decode(existingPrivateKey)['privateExponent']),
        BigInt.parse(json.decode(existingPrivateKey)['p']),
        BigInt.parse(json.decode(existingPrivateKey)['q']));

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
        publicKey, privateKey);
  }

  // Generate new key pair
  final keyGen = RSAKeyGenerator();
  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.from(65537), _keySize, 64),
      _getSecureRandom()));

  final keyPair = keyGen.generateKeyPair();
  final publicKey = keyPair.publicKey as RSAPublicKey;
  final privateKey = keyPair.privateKey as RSAPrivateKey;

  // Store keys
  await _secureStorage.write(
      key: _publicKeyTag,
      value: json.encode({
        'modulus': publicKey.modulus.toString(),
        'exponent': publicKey.exponent.toString()
      }));

  await _secureStorage.write(
      key: _privateKeyTag,
      value: json.encode({
        'modulus': privateKey.modulus.toString(),
        'privateExponent': privateKey.privateExponent.toString(),
        'p': privateKey.p.toString(),
        'q': privateKey.q.toString()
      }));

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
}

// Generate a secure random number generator
FortunaRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  final seeds = List<int>.generate(32, (_) => random.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}
