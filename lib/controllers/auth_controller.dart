import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum UserRole { participant, provider, unknown }

class AuthController extends ChangeNotifier {
  UserRole _role = UserRole.unknown;
  bool _signedIn = false;
  fb.User? _firebaseUser;
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  UserRole get role => _role;
  bool get signedIn => _signedIn;
  fb.User? get firebaseUser => _firebaseUser;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Backward-compatible getters expected by tests
  bool get isAuthenticated => signedIn;
  fb.User? get currentUser => _firebaseUser;
  UserRole? get userRole => _role == UserRole.unknown ? null : _role;

  static AuthController of(BuildContext context) =>
      context.read<AuthController>();

  Future<void> load() async {
    _setLoading(true);
    try {
      // Check Firebase auth state
      _firebaseUser = fb.FirebaseAuth.instance.currentUser;
      if (_firebaseUser != null) {
        _signedIn = true;
        _userId = _firebaseUser!.uid;

        // Load user role from Firestore
        await _loadUserRole();
      } else {
        // Fallback to local storage for demo/offline mode
        final prefs = await SharedPreferences.getInstance();
        final rawRole = prefs.getString('role');
        _role = switch (rawRole) {
          'participant' => UserRole.participant,
          'provider' => UserRole.provider,
          _ => UserRole.unknown,
        };
        _signedIn = prefs.getBool('signedIn') ?? false;
      }
    } catch (e) {
      _setError('Failed to load authentication state: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserRole() async {
    if (_userId == null) return;

    try {
      final userDoc = await FirestoreService.db
          ?.collection('users')
          .doc(_userId)
          .get();

      if (userDoc?.exists == true) {
        final data = userDoc!.data();
        final roleString = data?['role'] as String?;
        _role = switch (roleString) {
          'participant' => UserRole.participant,
          'provider' => UserRole.provider,
          _ => UserRole.unknown,
        };
      }
    } catch (e) {
      // Fallback to local storage if Firestore fails
      final prefs = await SharedPreferences.getInstance();
      final rawRole = prefs.getString('role');
      _role = switch (rawRole) {
        'participant' => UserRole.participant,
        'provider' => UserRole.provider,
        _ => UserRole.unknown,
      };
    }
    notifyListeners();
  }

  Future<bool> signInAnonymously() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await AuthService().signInAnonymously();
      if (user != null) {
        _firebaseUser = user;
        _signedIn = true;
        _userId = user.uid;

        // Save to local storage as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('signedIn', true);
        await prefs.setString('userId', user.uid);

        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        _firebaseUser = credential.user;
        _signedIn = true;
        _userId = credential.user!.uid;

        // Load user role
        await _loadUserRole();

        // Save to local storage as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('signedIn', true);
        await prefs.setString('userId', credential.user!.uid);

        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> createAccount(
    String email,
    String password,
    UserRole role,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        _firebaseUser = credential.user;
        _signedIn = true;
        _userId = credential.user!.uid;
        _role = role;

        // Save user role to Firestore
        await FirestoreService.save('users', _userId!, {
          'role': role.name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': DateTime.now().toIso8601String(),
        });

        // Save to local storage as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('signedIn', true);
        await prefs.setString('userId', credential.user!.uid);
        await prefs.setString('role', role.name);

        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('Account creation failed: $e');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService().signOut();
      _firebaseUser = null;
      _signedIn = false;
      _userId = null;
      _role = UserRole.unknown;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('signedIn');
      await prefs.remove('userId');
      await prefs.remove('role');

      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    notifyListeners();

    // Save to Firestore if user is signed in
    if (_userId != null) {
      try {
        await FirestoreService.save('users', _userId!, {
          'role': role.name,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role.name);
      }
    } else {
      // Save to local storage for offline mode
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', role.name);
    }
  }

  void setSignedIn(bool signedIn) {
    _signedIn = signedIn;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
