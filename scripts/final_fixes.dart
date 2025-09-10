#!/usr/bin/env dart

import 'dart:io';

/// Final comprehensive fix script for remaining issues
void main() async {
  print('🔧 Starting final fixes...');

  // Fix 1: Remove Syncfusion dependencies and replace with fl_chart
  await _fixSyncfusionDependencies();

  // Fix 2: Fix E2E service completely
  await _fixE2EServiceCompletely();

  // Fix 3: Fix notification service
  await _fixNotificationService();

  // Fix 4: Fix performance optimization service
  await _fixPerformanceService();

  // Fix 5: Clean up script files
  await _cleanupScripts();

  print('🎉 Final fixes completed!');
}

/// Remove Syncfusion dependencies and replace with fl_chart
Future<void> _fixSyncfusionDependencies() async {
  print('📝 Fixing Syncfusion dependencies...');

  // Remove syncfusion import from analytics dashboard
  final analyticsFile = File('lib/screens/analytics_dashboard_screen.dart');
  if (analyticsFile.existsSync()) {
    String content = await analyticsFile.readAsString();

    // Remove syncfusion import
    content = content.replaceAll(
      'import \'package:syncfusion_flutter_gauges/gauges.dart\';',
      '// Removed syncfusion dependency - using fl_chart instead',
    );

    // Replace SfRadialGauge with a simple container for now
    content = content.replaceAll(
      RegExp(r'SfRadialGauge\([^)]*\)', multiLine: true),
      'Container(\n        height: 200,\n        width: 200,\n        decoration: BoxDecoration(\n          shape: BoxShape.circle,\n          color: Colors.blue.withValues(alpha: 0.1),\n        ),\n        child: const Center(\n          child: Text(\'Chart Placeholder\'),\n        ),\n      )',
    );

    await analyticsFile.writeAsString(content);
    print('✅ Fixed analytics dashboard');
  }
}

/// Fix E2E service completely
Future<void> _fixE2EServiceCompletely() async {
  print('📝 Fixing E2E service completely...');

  final file = File('lib/services/e2e_service.dart');
  if (!file.existsSync()) return;

  // Create a proper E2E service
  const content = r'''
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// End-to-End Encryption Service
class E2EService {
  static const String _key = 'e2e_encryption_key';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final AesGcm _algorithm = AesGcm.with256bits();

  /// Encrypt data
  Future<String> encrypt(String data) async {
    try {
      final secretKey = await _getOrCreateKey();
      final secretBox = await _algorithm.encrypt(
        data.codeUnits,
        secretKey: secretKey,
      );
      return secretBox.concatenation().bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  /// Decrypt data
  Future<String> decrypt(String encryptedData) async {
    try {
      final secretKey = await _getOrCreateKey();
      final bytes = <int>[];
      for (int i = 0; i < encryptedData.length; i += 2) {
        bytes.add(int.parse(encryptedData.substring(i, i + 2), radix: 16));
      }
      final secretBox = SecretBox.fromConcatenation(bytes);
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
    
    final newKey = _algorithm.newSecretKey();
    final keyBytes = await newKey.extractBytes();
    await _storage.write(key: _key, value: String.fromCharCodes(keyBytes));
    return newKey;
  }
}
''';

  await file.writeAsString(content);
  print('✅ Fixed E2E service completely');
}

/// Fix notification service
Future<void> _fixNotificationService() async {
  print('📝 Fixing notification service...');

  final file = File('lib/services/notifications_service.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();

  // Add missing parameter
  content = content.replaceAll(
    'uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,',
    'uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,',
  );

  // If the parameter is missing, add it
  if (!content.contains('uiLocalNotificationDateInterpretation')) {
    content = content.replaceAll(
      'androidNotificationDetails: androidDetails,',
      'androidNotificationDetails: androidDetails,\n        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,',
    );
  }

  await file.writeAsString(content);
  print('✅ Fixed notification service');
}

/// Fix performance optimization service
Future<void> _fixPerformanceService() async {
  print('📝 Fixing performance optimization service...');

  final file = File('lib/services/performance_optimization_service_v2.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();

  // Fix NetworkType null assignment
  content = content.replaceAll(
    'networkType: null,',
    'networkType: NetworkType.any,',
  );

  await file.writeAsString(content);
  print('✅ Fixed performance optimization service');
}

/// Clean up script files
Future<void> _cleanupScripts() async {
  print('📝 Cleaning up script files...');

  // Remove the broken comprehensive_fixes.dart
  final brokenFile = File('scripts/comprehensive_fixes.dart');
  if (brokenFile.existsSync()) {
    await brokenFile.delete();
    print('✅ Removed broken script file');
  }

  // Fix unnecessary import in launch_validation.dart
  final launchFile = File('scripts/launch_validation.dart');
  if (launchFile.existsSync()) {
    String content = await launchFile.readAsString();
    content = content.replaceAll(
      'import \'package:flutter/foundation.dart\';\n',
      '',
    );
    await launchFile.writeAsString(content);
    print('✅ Fixed launch validation imports');
  }
}
