import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_database_service.dart';

class LocalAuthService {
  factory LocalAuthService() => _instance;
  LocalAuthService._internal();
  static final LocalAuthService _instance = LocalAuthService._internal();

  final LocalDatabaseService _db = LocalDatabaseService();
  String? _currentUserId;

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId != null) {
      _currentUserId = userId;
      return true;
    }
    return false;
  }

  // Register a new user
  Future<Map<String, dynamic>> register({
    required final String email,
    required final String password,
    required final String name,
    required final String role,
  }) async {
    try {
      // Check if user already exists
      final existingUsers = await _db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUsers.isNotEmpty) {
        return {
          'success': false,
          'error': 'User with this email already exists',
        };
      }

      // Create new user
      final userId = _generateUserId();
      final hashedPassword = _hashPassword(password);

      await _db.insert('users', {
        'id': userId,
        'email': email,
        'name': name,
        'role': role,
        'password_hash': hashedPassword, // In real app, store this securely
      });

      // Auto-login after registration
      await _loginUser(userId);

      return {
        'success': true,
        'user': {
          'id': userId,
          'email': email,
          'name': name,
          'role': role,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required final String email,
    required final String password,
  }) async {
    try {
      final users = await _db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'error': 'User not found',
        };
      }

      final user = users.first;
      // In a real app, you'd compare hashed passwords
      // For demo purposes, we'll skip password verification
      await _loginUser(user['id'] as String);

      return {
        'success': true,
        'user': {
          'id': user['id'],
          'email': user['email'],
          'name': user['name'],
          'role': user['role'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    _currentUserId = null;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUserId == null) {
      final isLoggedIn = await this.isLoggedIn();
      if (!isLoggedIn) return null;
    }

    final users = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [_currentUserId],
    );

    if (users.isEmpty) return null;

    final user = users.first;
    return {
      'id': user['id'],
      'email': user['email'],
      'name': user['name'],
      'role': user['role'],
    };
  }

  // Private helper methods
  Future<void> _loginUser(final String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    _currentUserId = userId;
  }

  String _generateUserId() => DateTime.now().millisecondsSinceEpoch.toString();

  String _hashPassword(final String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
