import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_auth_service.dart';

enum UserRole { participant, provider, unknown }

class AuthController extends ChangeNotifier {
  UserRole _role = UserRole.unknown;
  bool _signedIn = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;
  String? _errorMessage;

  final LocalAuthService _authService = LocalAuthService();

  UserRole get role => _role;
  bool get signedIn => _signedIn;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Backward-compatible getters
  bool get isAuthenticated => signedIn;
  UserRole? get userRole => _role == UserRole.unknown ? null : _role;

  static AuthController of(BuildContext context) =>
      Provider.of<AuthController>(context, listen: false);

  Future<void> load() async {
    _setLoading(true);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _userId = user['id'];
          _userEmail = user['email'];
          _userName = user['name'];
          _role = _parseRole(user['role']);
          _signedIn = true;
        }
      }
    } catch (e) {
      _setError('Failed to load authentication state: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(email: email, password: password);
      
      if (result['success']) {
        final user = result['user'];
        _userId = user['id'];
        _userEmail = user['email'];
        _userName = user['name'];
        _role = _parseRole(user['role']);
        _signedIn = true;
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role.name,
      );
      
      if (result['success']) {
        final user = result['user'];
        _userId = user['id'];
        _userEmail = user['email'];
        _userName = user['name'];
        _role = _parseRole(user['role']);
        _signedIn = true;
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _clearUserData();
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _clearUserData() {
    _role = UserRole.unknown;
    _signedIn = false;
    _userId = null;
    _userEmail = null;
    _userName = null;
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

  UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'participant':
        return UserRole.participant;
      case 'provider':
        return UserRole.provider;
      default:
        return UserRole.unknown;
    }
  }
}
