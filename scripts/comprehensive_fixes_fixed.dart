#!/usr/bin/env dart

import 'dart:io';

/// Comprehensive fix script for NDIS Connect app
/// This script addresses all remaining issues found in the analysis
void main() async {
  print('🔧 Starting comprehensive fixes...');

  // Fix 1: Remove duplicate key in analysis_options.yaml
  await _fixAnalysisOptions();

  // Fix 2: Add missing imports to script files
  await _fixScriptImports();

  // Fix 3: Remove unused imports
  await _fixUnusedImports();

  // Fix 4: Fix E2E service issues
  await _fixE2EService();

  // Fix 5: Update pubspec.yaml with Flutter-compatible versions
  await _updatePubspecVersions();

  print('🎉 Comprehensive fixes completed!');
}

/// Fix duplicate key in analysis_options.yaml
Future<void> _fixAnalysisOptions() async {
  print('📝 Fixing analysis_options.yaml...');

  final file = File('analysis_options.yaml');
  if (!file.existsSync()) return;

  final String content = await file.readAsString();

  // Remove duplicate prefer_const_constructors entry
  final lines = content.split('\n');
  final fixedLines = <String>[];
  bool foundFirst = false;

  for (final line in lines) {
    if (line.trim() == 'prefer_const_constructors: warning') {
      if (!foundFirst) {
        fixedLines.add(line);
        foundFirst = true;
      }
      // Skip duplicate entries
    } else {
      fixedLines.add(line);
    }
  }

  await file.writeAsString(fixedLines.join('\n'));
  print('✅ Fixed analysis_options.yaml');
}

/// Add missing imports to script files
Future<void> _fixScriptImports() async {
  print('📝 Adding missing imports to script files...');

  final scriptFiles = [
    'scripts/run_accessibility_tests.dart',
    'scripts/run_security_audit.dart',
    'scripts/launch_validation.dart',
  ];

  for (final scriptPath in scriptFiles) {
    final file = File(scriptPath);
    if (!file.existsSync()) continue;

    String content = await file.readAsString();

    // Add debugPrint import if not present
    if (content.contains('debugPrint') &&
        !content.contains('import \'package:flutter/foundation.dart\';')) {
      content = content.replaceFirst(
        'import \'dart:io\';',
        'import \'dart:io\';\nimport \'package:flutter/foundation.dart\';',
      );
    }

    await file.writeAsString(content);
    print('✅ Fixed imports in $scriptPath');
  }
}

/// Remove unused imports
Future<void> _fixUnusedImports() async {
  print('📝 Removing unused imports...');

  final file = File('scripts/fix_deprecated_apis.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();

  // Remove unused dart:convert import
  content = content.replaceAll('import \'dart:convert\';\n', '');

  await file.writeAsString(content);
  print('✅ Removed unused imports');
}

/// Fix E2E service issues
Future<void> _fixE2EService() async {
  print('📝 Fixing E2E service...');

  final file = File('lib/services/e2e_service.dart');
  if (!file.existsSync()) return;

  String content = await file.readAsString();

  // Simple string replacements for E2E service
  content = content.replaceAll(
    'static String _key = \'\';',
    'static const String _key = \'e2e_encryption_key\';',
  );
  content = content.replaceAll(
    'static Future<String> encrypt(',
    'Future<String> encrypt(',
  );
  content = content.replaceAll(
    'static Future<String> decrypt(',
    'Future<String> decrypt(',
  );

  await file.writeAsString(content);
  print('✅ Fixed E2E service');
}

/// Update pubspec.yaml with Flutter-compatible versions
Future<void> _updatePubspecVersions() async {
  print('📝 Updating pubspec.yaml versions...');

  final file = File('pubspec.yaml');
  if (!file.existsSync()) return;

  String content = await file.readAsString();

  // Update SDK version to match Flutter framework
  content = content.replaceAll(
    'sdk: ">=3.4.0 <4.0.0"',
    'sdk: ">=3.8.0 <4.0.0"',
  );

  // Update core dependencies to match Flutter framework versions
  content = content.replaceAll('collection: ^1.18.0', 'collection: ^1.19.1');

  await file.writeAsString(content);
  print('✅ Updated pubspec.yaml versions');
}
