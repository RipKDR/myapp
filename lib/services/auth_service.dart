import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<fb.User?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();
}

