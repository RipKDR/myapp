import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// End-to-End Encryption Service
class E2EService {
  static const String _key = 'e2e_encryption_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final AesGcm _algorithm = AesGcm.with256bits();

  /// Encrypt data
  Future<String> encrypt(final String data) async {
    try {
      final secretKey = await _getOrCreateKey();
      final secretBox = await _algorithm.encrypt(
        data.codeUnits,
        secretKey: secretKey,
      );
      return secretBox
          .concatenation()
          .map((final b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt data
  Future<String> decrypt(final String encryptedData) async {
    try {
      final secretKey = await _getOrCreateKey();
      final bytes = <int>[];
      for (int i = 0; i < encryptedData.length; i += 2) {
        bytes.add(int.parse(encryptedData.substring(i, i + 2), radix: 16));
      }
      final secretBox = SecretBox.fromConcatenation(
        bytes,
        macLength: 16,
        nonceLength: 12,
      );
      final decrypted = await _algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      return String.fromCharCodes(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Get or create encryption key
  Future<SecretKey> _getOrCreateKey() async {
    final keyString = await _storage.read(key: _key);
    if (keyString != null) {
      return SecretKey(keyString.codeUnits);
    }

    final newKey = await _algorithm.newSecretKey();
    final keyBytes = await newKey.extractBytes();
    await _storage.write(key: _key, value: String.fromCharCodes(keyBytes));
    return newKey;
  }

  /// Check if encryption key exists
  Future<bool> hasKey() async {
    final keyString = await _storage.read(key: _key);
    return keyString != null;
  }

  /// Set passphrase for encryption
  Future<void> setPassphrase(final String passphrase) async {
    // Store passphrase securely
    await _storage.write(key: '${_key}_passphrase', value: passphrase);
  }
}
