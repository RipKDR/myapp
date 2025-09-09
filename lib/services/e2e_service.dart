import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../utils/crypto.dart';

class E2EService {
  static const _kSalt = 'circle_salt';
  static const _kCheck = 'circle_check';
  static const _storage = FlutterSecureStorage();
  static SecretKey? _key;

  static Future<bool> hasKey() async {
    final salt = await _storage.read(key: _kSalt);
    final check = await _storage.read(key: _kCheck);
    return salt != null && check != null;
  }

  static Future<void> setPassphrase(String passphrase) async {
    var saltB64 = await _storage.read(key: _kSalt);
    List<int> salt;
    if (saltB64 == null) {
      // Generate salt using a cryptographically secure PRNG
      final rnd = Random.secure();
      salt = List<int>.generate(16, (_) => rnd.nextInt(256));
      await _storage.write(key: _kSalt, value: base64Encode(salt));
    } else {
      salt = base64Decode(saltB64);
    }
    final key = await E2ECrypto.deriveKey(passphrase: passphrase, salt: salt);
    _key = key;
    final payload = await E2ECrypto.encrypt(key: key, plaintext: 'ok');
    await _storage.write(key: _kCheck, value: jsonEncode(payload));
  }

  static Future<bool> verifyPassphrase(String passphrase) async {
    final saltB64 = await _storage.read(key: _kSalt);
    final check = await _storage.read(key: _kCheck);
    if (saltB64 == null || check == null) return false;
    final key = await E2ECrypto.deriveKey(
        passphrase: passphrase, salt: base64Decode(saltB64));
    try {
      await E2ECrypto.decrypt(
          key: key, payload: Map<String, String>.from(jsonDecode(check)));
      _key = key;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>> encrypt(String text) async {
    if (_key == null) throw StateError('No passphrase set');
    return E2ECrypto.encrypt(key: _key!, plaintext: text);
  }

  static Future<String?> decrypt(Map<String, String> payload) async {
    if (_key == null) return null;
    try {
      return await E2ECrypto.decrypt(key: _key!, payload: payload);
    } catch (_) {
      return null;
    }
  }
}
