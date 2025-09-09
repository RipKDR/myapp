import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This file will be replaced by FlutterFire's generated options in production.
// Keep a permissive stub to avoid compile errors before configuration.
import '../firebase_options.dart';
import 'notifications_service.dart';
import 'firestore_service.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool get initialized => _initialized;

  static Future<void> tryInitialize() async {
    if (_initialized) return;
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.isEmpty ||
          options.appId.isEmpty ||
          options.projectId.isEmpty) {
        // Skip init if not configured to avoid runtime crashes in dev.
        log('Firebase not configured via --dart-define; running offline mode');
        return;
      }

      await Firebase.initializeApp(options: options);

      // Enable Firestore offline persistence
      await _enableOfflinePersistence();

      _initialized = true;
      log('Firebase initialized successfully');

      // Initialize notifications after Firebase is ready
      await NotificationsService.initialize();
    } catch (e) {
      // Non-fatal before configuration. Log and continue with offline-first UX.
      log('Firebase init skipped: $e');
    }
  }

  static Future<void> _enableOfflinePersistence() async {
    try {
      await FirestoreService.enableOfflinePersistence();
      log('Firestore offline persistence enabled');
    } catch (e) {
      log('Failed to enable offline persistence: $e');
      // Continue without offline persistence
    }
  }

  // Check if Firebase is properly configured
  static bool get isConfigured {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return options.apiKey.isNotEmpty &&
          options.appId.isNotEmpty &&
          options.projectId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get current user ID for debugging
  static String? get currentUserId {
    try {
      return FirebaseFirestore.instance.app.name;
    } catch (e) {
      return null;
    }
  }
}
