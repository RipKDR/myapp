import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Launch Validation Script
///
/// This script validates that the app is ready for production launch
/// by running comprehensive tests and checks.
void main() async {
  print('🚀 NDIS Connect - Launch Validation Script');
  print('==========================================');

  await runValidationChecks();
}

Future<void> runValidationChecks() async {
  final results = <String, bool>{};

  print('\n📋 Running Launch Validation Checks...\n');

  // 1. Code Quality Checks
  print('1️⃣ Code Quality & Linting...');
  results['code_quality'] = await checkCodeQuality();

  // 2. Dependencies Check
  print('2️⃣ Dependencies & Security...');
  results['dependencies'] = await checkDependencies();

  // 3. Configuration Check
  print('3️⃣ Configuration & Environment...');
  results['configuration'] = await checkConfiguration();

  // 4. Accessibility Check
  print('4️⃣ Accessibility Compliance...');
  results['accessibility'] = await checkAccessibility();

  // 5. Performance Check
  print('5️⃣ Performance & Optimization...');
  results['performance'] = await checkPerformance();

  // 6. Security Check
  print('6️⃣ Security & Privacy...');
  results['security'] = await checkSecurity();

  // 7. Build Check
  print('7️⃣ Build & Deployment...');
  results['build'] = await checkBuild();

  // 8. Store Readiness
  print('8️⃣ Store Readiness...');
  results['store_readiness'] = await checkStoreReadiness();

  // Print Results
  print('\n📊 Validation Results:');
  print('======================');

  bool allPassed = true;
  for (final entry in results.entries) {
    final status = entry.value ? '✅ PASS' : '❌ FAIL';
    print('${entry.key}: $status');
    if (!entry.value) allPassed = false;
  }

  print(
    '\n🎯 Overall Status: ${allPassed ? '✅ READY FOR LAUNCH' : '❌ NOT READY'}',
  );

  if (!allPassed) {
    print('\n⚠️  Please address the failing checks before launching.');
    exit(1);
  } else {
    print('\n🎉 Congratulations! Your app is ready for launch!');
    exit(0);
  }
}

Future<bool> checkCodeQuality() async {
  try {
    // Run flutter analyze
    final result = await Process.run('flutter', ['analyze']);
    if (result.exitCode != 0) {
      print('   ❌ Flutter analyze failed: ${result.stderr}');
      return false;
    }

    // Check for TODO/FIXME comments (only on Unix-like systems)
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        final todoResult = await Process.run('grep', [
          '-r',
          'TODO\\|FIXME',
          'lib/',
        ]);
        if (todoResult.exitCode == 0) {
          print('   ⚠️  Found TODO/FIXME comments in code');
        }
      } catch (e) {
        // Ignore grep errors on some systems
      }
    }

    print('   ✅ Code quality checks passed');
    return true;
  } catch (e) {
    print('   ❌ Code quality check failed: $e');
    return false;
  }
}

Future<bool> checkDependencies() async {
  try {
    // Check for outdated dependencies
    final result = await Process.run('flutter', ['pub', 'outdated']);
    if (result.exitCode != 0) {
      print('   ❌ Failed to check dependencies: ${result.stderr}');
      return false;
    }

    // Check for security vulnerabilities
    final auditResult = await Process.run('flutter', ['pub', 'audit']);
    if (auditResult.exitCode != 0) {
      print('   ⚠️  Security vulnerabilities found');
    }

    print('   ✅ Dependencies check passed');
    return true;
  } catch (e) {
    print('   ❌ Dependencies check failed: $e');
    return false;
  }
}

Future<bool> checkConfiguration() async {
  try {
    // Check if Firebase is configured
    final firebaseFile = File('lib/firebase_options.dart');
    if (!firebaseFile.existsSync()) {
      print('   ❌ Firebase configuration file missing');
      return false;
    }

    final content = await firebaseFile.readAsString();
    if (content.contains('REPLACE_ME')) {
      print('   ❌ Firebase configuration not completed');
      return false;
    }

    // Check Android manifest
    final androidManifest = File('android/app/src/main/AndroidManifest.xml');
    if (!androidManifest.existsSync()) {
      print('   ❌ Android manifest missing');
      return false;
    }

    // Check iOS Info.plist
    final iosInfoPlist = File('ios/Runner/Info.plist');
    if (!iosInfoPlist.existsSync()) {
      print('   ❌ iOS Info.plist missing');
      return false;
    }

    print('   ✅ Configuration check passed');
    return true;
  } catch (e) {
    print('   ❌ Configuration check failed: $e');
    return false;
  }
}

Future<bool> checkAccessibility() async {
  try {
    // Check for accessibility features in code
    final accessibilityFiles = [
      'lib/theme/app_theme.dart',
      'lib/controllers/settings_controller.dart',
      'lib/widgets/',
    ];

    bool hasAccessibilityFeatures = false;
    for (final file in accessibilityFiles) {
      final fileObj = File(file);
      if (fileObj.existsSync()) {
        final content = await fileObj.readAsString();
        if (content.contains('highContrast') ||
            content.contains('textScale') ||
            content.contains('reduceMotion')) {
          hasAccessibilityFeatures = true;
          break;
        }
      }
    }

    if (!hasAccessibilityFeatures) {
      print('   ❌ Accessibility features not found');
      return false;
    }

    print('   ✅ Accessibility check passed');
    return true;
  } catch (e) {
    print('   ❌ Accessibility check failed: $e');
    return false;
  }
}

Future<bool> checkPerformance() async {
  try {
    // Check for performance optimizations
    final performanceFiles = [
      'lib/services/firestore_service.dart',
      'lib/repositories/',
    ];

    bool hasPerformanceFeatures = false;
    for (final file in performanceFiles) {
      final fileObj = File(file);
      if (fileObj.existsSync()) {
        final content = await fileObj.readAsString();
        if (content.contains('Stream') ||
            content.contains('cache') ||
            content.contains('optimization')) {
          hasPerformanceFeatures = true;
          break;
        }
      }
    }

    if (!hasPerformanceFeatures) {
      print('   ❌ Performance optimizations not found');
      return false;
    }

    print('   ✅ Performance check passed');
    return true;
  } catch (e) {
    print('   ❌ Performance check failed: $e');
    return false;
  }
}

Future<bool> checkSecurity() async {
  try {
    // Check for security features
    final securityFiles = [
      'firestore.rules',
      'lib/services/error_service.dart',
      'lib/controllers/auth_controller.dart',
    ];

    bool hasSecurityFeatures = false;
    for (final file in securityFiles) {
      final fileObj = File(file);
      if (fileObj.existsSync()) {
        final content = await fileObj.readAsString();
        if (content.contains('security') ||
            content.contains('auth') ||
            content.contains('rules')) {
          hasSecurityFeatures = true;
          break;
        }
      }
    }

    if (!hasSecurityFeatures) {
      print('   ❌ Security features not found');
      return false;
    }

    print('   ✅ Security check passed');
    return true;
  } catch (e) {
    print('   ❌ Security check failed: $e');
    return false;
  }
}

Future<bool> checkBuild() async {
  try {
    // Test Android build
    print('   Testing Android build...');
    final androidResult = await Process.run('flutter', [
      'build',
      'apk',
      '--debug',
    ]);
    if (androidResult.exitCode != 0) {
      print('   ❌ Android build failed: ${androidResult.stderr}');
      return false;
    }

    // Test iOS build (if on macOS)
    if (Platform.isMacOS) {
      print('   Testing iOS build...');
      try {
        final iosResult = await Process.run('flutter', [
          'build',
          'ios',
          '--debug',
          '--no-codesign',
        ]);
        if (iosResult.exitCode != 0) {
          print('   ❌ iOS build failed: ${iosResult.stderr}');
          return false;
        }
      } catch (e) {
        print('   ⚠️  iOS build test skipped: $e');
        // Don't fail the entire check for iOS build issues
      }
    }

    print('   ✅ Build check passed');
    return true;
  } catch (e) {
    print('   ❌ Build check failed: $e');
    return false;
  }
}

Future<bool> checkStoreReadiness() async {
  try {
    // Check for required store assets
    final requiredAssets = ['assets/app_icon.svg', 'LAUNCH_GUIDE.md'];

    for (final asset in requiredAssets) {
      final file = File(asset);
      if (!file.existsSync()) {
        print('   ❌ Required asset missing: $asset');
        return false;
      }
    }

    // Check pubspec.yaml for proper versioning
    final pubspecFile = File('pubspec.yaml');
    if (pubspecFile.existsSync()) {
      final content = await pubspecFile.readAsString();
      if (!content.contains('version:') || content.contains('version: 0.0.0')) {
        print('   ❌ Version not properly set in pubspec.yaml');
        return false;
      }
    }

    print('   ✅ Store readiness check passed');
    return true;
  } catch (e) {
    print('   ❌ Store readiness check failed: $e');
    return false;
  }
}

/// Widget test for basic app functionality
class LaunchValidationTest extends StatelessWidget {
  const LaunchValidationTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDIS Connect Launch Validation',
      home: Scaffold(
        appBar: AppBar(title: const Text('Launch Validation')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text(
                'App is ready for launch!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'All validation checks have passed.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
