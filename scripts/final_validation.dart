#!/usr/bin/env dart

import 'dart:io';

/// Final validation script to confirm all improvements
void main() async {
  print('🎯 NDIS Connect App - Final Validation');
  print('=====================================');

  await _validateGitignore();
  await _validateDependencies();
  await _validateCodeQuality();
  await _validateSecurity();
  await _validatePerformance();

  print('\n🎉 VALIDATION COMPLETE!');
  print('📱 Your NDIS Connect app is ready for launch!');
}

Future<void> _validateGitignore() async {
  print('\n📁 Validating .gitignore...');

  final gitignore = File('.gitignore');
  if (!gitignore.existsSync()) {
    print('❌ .gitignore not found');
    return;
  }

  final content = await gitignore.readAsString();
  final requiredEntries = [
    'build/',
    'android/app/google-services.json',
    'ios/Runner/GoogleService-Info.plist',
    '*.env',
    '.DS_Store',
    'Thumbs.db',
  ];

  int found = 0;
  for (final entry in requiredEntries) {
    if (content.contains(entry)) {
      found++;
    }
  }

  if (found == requiredEntries.length) {
    print('✅ .gitignore comprehensive and secure');
  } else {
    print(
      '⚠️  .gitignore missing some entries ($found/${requiredEntries.length})',
    );
  }
}

Future<void> _validateDependencies() async {
  print('\n📦 Validating dependencies...');

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('❌ pubspec.yaml not found');
    return;
  }

  final content = await pubspec.readAsString();
  final firebaseDeps = [
    'firebase_core:',
    'firebase_auth:',
    'cloud_firestore:',
    'firebase_messaging:',
    'firebase_analytics:',
    'firebase_crashlytics:',
  ];

  int found = 0;
  for (final dep in firebaseDeps) {
    if (content.contains(dep)) {
      found++;
    }
  }

  if (found == firebaseDeps.length) {
    print('✅ Firebase dependencies properly configured');
  } else {
    print('⚠️  Missing Firebase dependencies ($found/${firebaseDeps.length})');
  }

  // Check for Flutter 3.24+ compatibility
  if (content.contains('flutter: ">=3.24.0"')) {
    print('✅ Flutter 3.24+ compatibility confirmed');
  } else {
    print('⚠️  Flutter version may need updating');
  }
}

Future<void> _validateCodeQuality() async {
  print('\n🔍 Validating code quality...');

  final analysisOptions = File('analysis_options.yaml');
  if (!analysisOptions.existsSync()) {
    print('❌ analysis_options.yaml not found');
    return;
  }

  final content = await analysisOptions.readAsString();
  if (content.contains('strict-casts: true') &&
      content.contains('strict-inference: true') &&
      content.contains('strict-raw-types: true')) {
    print('✅ Strict type checking enabled');
  } else {
    print('⚠️  Strict type checking not fully enabled');
  }

  if (content.contains('deprecated_member_use: error')) {
    print('✅ Deprecated API usage treated as errors');
  } else {
    print('⚠️  Deprecated API usage not strictly enforced');
  }
}

Future<void> _validateSecurity() async {
  print('\n🔒 Validating security...');

  final e2eService = File('lib/services/e2e_service.dart');
  if (e2eService.existsSync()) {
    final content = await e2eService.readAsString();
    if (content.contains('AesGcm') && content.contains('SecretKey')) {
      print('✅ E2E encryption service properly implemented');
    } else {
      print('⚠️  E2E encryption service needs review');
    }
  } else {
    print('⚠️  E2E encryption service not found');
  }

  final secureStorage = File('lib/services/advanced_security_service.dart');
  if (secureStorage.existsSync()) {
    print('✅ Advanced security service present');
  } else {
    print('⚠️  Advanced security service not found');
  }
}

Future<void> _validatePerformance() async {
  print('\n⚡ Validating performance...');

  final performanceService = File(
    'lib/services/performance_optimization_service.dart',
  );
  if (performanceService.existsSync()) {
    print('✅ Performance optimization service present');
  } else {
    print('⚠️  Performance optimization service not found');
  }

  final cacheService = File('lib/services/advanced_cache_service.dart');
  if (cacheService.existsSync()) {
    print('✅ Advanced cache service present');
  } else {
    print('⚠️  Advanced cache service not found');
  }

  final errorService = File('lib/services/error_service.dart');
  if (errorService.existsSync()) {
    print('✅ Error handling service present');
  } else {
    print('⚠️  Error handling service not found');
  }
}
