import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'dart:math';

// Simple E2E helpers: derive a key from a passphrase and encrypt/decrypt text.

class E2ECrypto {
  static final _algo = AesGcm.with256bits();

  static Future<SecretKey> deriveKey({
    required String passphrase,
    required List<int> salt,
    int iterations = 150000,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static Future<Map<String, String>> encrypt({
    required SecretKey key,
    required String plaintext,
  }) async {
    final nonce = randomBytes(12);
    final secretBox = await _algo.encrypt(utf8.encode(plaintext),
        secretKey: key, nonce: nonce);
    return {
      'n': base64Encode(nonce),
      'c': base64Encode(secretBox.cipherText),
      't': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<String> decrypt({
    required SecretKey key,
    required Map<String, String> payload,
  }) async {
    final nonce = base64Decode(payload['n']!);
    final cipher = base64Decode(payload['c']!);
    final mac = Mac(base64Decode(payload['t']!));
    final box = SecretBox(cipher, nonce: nonce, mac: mac);
    final data = await _algo.decrypt(box, secretKey: key);
    return utf8.decode(data);
  }

  static List<int> randomBytes(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }
}
