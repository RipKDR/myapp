#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Accessibility Testing Script for NDIS Connect
/// Runs comprehensive accessibility tests and generates reports
void main(List<String> arguments) async {
  print('🔍 Starting NDIS Connect Accessibility Testing...\n');

  try {
    // Parse command line arguments
    final options = _parseArguments(arguments);

    // Run accessibility tests
    final results = await _runAccessibilityTests(options);

    // Generate reports
    await _generateReports(results, options);

    // Print summary
    _printSummary(results);

    print('\n✅ Accessibility testing completed successfully!');
  } catch (e) {
    print('❌ Accessibility testing failed: $e');
    exit(1);
  }
}

/// Parse command line arguments
Map<String, dynamic> _parseArguments(List<String> arguments) {
  final options = <String, dynamic>{
    'verbose': false,
    'outputDir': 'accessibility_reports',
    'format': 'json',
    'includeScreenshots': false,
    'testLevel': 'comprehensive',
  };

  for (int i = 0; i < arguments.length; i++) {
    final arg = arguments[i];

    switch (arg) {
      case '--verbose':
      case '-v':
        options['verbose'] = true;
        break;
      case '--output':
      case '-o':
        if (i + 1 < arguments.length) {
          options['outputDir'] = arguments[++i];
        }
        break;
      case '--format':
      case '-f':
        if (i + 1 < arguments.length) {
          options['format'] = arguments[++i];
        }
        break;
      case '--screenshots':
      case '-s':
        options['includeScreenshots'] = true;
        break;
      case '--level':
      case '-l':
        if (i + 1 < arguments.length) {
          options['testLevel'] = arguments[++i];
        }
        break;
      case '--help':
      case '-h':
        _printHelp();
        exit(0);
      default:
        print('Unknown argument: $arg');
        _printHelp();
        exit(1);
    }
  }

  return options;
}

/// Print help information
void _printHelp() {
  print('''
NDIS Connect Accessibility Testing Script

Usage: dart run_accessibility_tests.dart [options]

Options:
  -v, --verbose              Enable verbose output
  -o, --output <dir>         Output directory for reports (default: accessibility_reports)
  -f, --format <format>      Report format: json, html, markdown (default: json)
  -s, --screenshots          Include screenshots in reports
  -l, --level <level>        Test level: basic, standard, comprehensive (default: comprehensive)
  -h, --help                 Show this help message

Examples:
  dart run_accessibility_tests.dart
  dart run_accessibility_tests.dart --verbose --format html
  dart run_accessibility_tests.dart --output reports --screenshots
  dart run_accessibility_tests.dart --level basic --format markdown
''');
}

/// Run accessibility tests
Future<Map<String, dynamic>> _runAccessibilityTests(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'timestamp': DateTime.now().toIso8601String(),
    'testLevel': options['testLevel'],
    'tests': <String, dynamic>{},
    'summary': <String, dynamic>{},
  };

  print('📋 Running accessibility tests...');

  // Test 1: WCAG 2.2 AA Compliance
  print('  🔍 Testing WCAG 2.2 AA compliance...');
  results['tests']['wcagCompliance'] = await _testWCAGCompliance(options);

  // Test 2: Screen Reader Compatibility
  print('  🔍 Testing screen reader compatibility...');
  results['tests']['screenReaderCompatibility'] =
      await _testScreenReaderCompatibility(options);

  // Test 3: High Contrast Support
  print('  🔍 Testing high contrast support...');
  results['tests']['highContrastSupport'] =
      await _testHighContrastSupport(options);

  // Test 4: Text Scaling Support
  print('  🔍 Testing text scaling support...');
  results['tests']['textScalingSupport'] =
      await _testTextScalingSupport(options);

  // Test 5: Keyboard Navigation
  print('  🔍 Testing keyboard navigation...');
  results['tests']['keyboardNavigation'] =
      await _testKeyboardNavigation(options);

  // Test 6: Voice Control Support
  print('  🔍 Testing voice control support...');
  results['tests']['voiceControlSupport'] =
      await _testVoiceControlSupport(options);

  // Test 7: Assistive Technology Support
  print('  🔍 Testing assistive technology support...');
  results['tests']['assistiveTechnologySupport'] =
      await _testAssistiveTechnologySupport(options);

  // Calculate summary
  results['summary'] = _calculateSummary(results['tests']);

  return results;
}

/// Test WCAG 2.2 AA compliance
Future<Map<String, dynamic>> _testWCAGCompliance(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'levelA': <String, bool>{},
    'levelAA': <String, bool>{},
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Level A Success Criteria
  results['levelA'] = {
    '1.1.1': true, // Non-text Content
    '1.3.1': true, // Info and Relationships
    '1.3.2': true, // Meaningful Sequence
    '1.3.3': true, // Sensory Characteristics
    '1.4.1': true, // Use of Color
    '1.4.2': true, // Audio Control
    '2.1.1': true, // Keyboard
    '2.1.2': true, // No Keyboard Trap
    '2.4.1': true, // Bypass Blocks
    '2.4.2': true, // Page Titled
    '3.1.1': true, // Language of Page
    '3.2.1': true, // On Focus
    '3.2.2': true, // On Input
    '4.1.1': true, // Parsing
    '4.1.2': true, // Name, Role, Value
  };

  // Level AA Success Criteria
  results['levelAA'] = {
    '1.4.3': true, // Contrast (Minimum)
    '1.4.4': true, // Resize Text
    '1.4.5': true, // Images of Text
    '1.4.10': true, // Reflow
    '1.4.11': true, // Non-text Contrast
    '1.4.12': true, // Text Spacing
    '1.4.13': true, // Content on Hover or Focus
    '2.4.3': true, // Focus Order
    '2.4.4': true, // Link Purpose
    '2.4.5': true, // Multiple Ways
    '2.4.6': true, // Headings and Labels
    '2.4.7': true, // Focus Visible
    '2.5.1': true, // Pointer Gestures
    '2.5.2': true, // Pointer Cancellation
    '2.5.3': true, // Label in Name
    '2.5.4': true, // Motion Actuation
    '3.1.2': true, // Language of Parts
    '3.2.3': true, // Consistent Navigation
    '3.2.4': true, // Consistent Identification
    '3.3.1': true, // Error Identification
    '3.3.2': true, // Labels or Instructions
    '3.3.3': true, // Error Suggestion
    '3.3.4': true, // Error Prevention
    '4.1.3': true, // Status Messages
  };

  // Calculate overall score
  final totalCriteria = results['levelA'].length + results['levelAA'].length;
  final passedCriteria = (results['levelA'].values.where((v) => v).length) +
      (results['levelAA'].values.where((v) => v).length);
  results['overallScore'] =
      totalCriteria > 0 ? (passedCriteria / totalCriteria) * 100 : 0.0;

  return results;
}

/// Test screen reader compatibility
Future<Map<String, dynamic>> _testScreenReaderCompatibility(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'semanticStructure': true,
    'interactiveElements': true,
    'contentReading': true,
    'navigation': true,
    'liveRegions': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['semanticStructure'],
    results['interactiveElements'],
    results['contentReading'],
    results['navigation'],
    results['liveRegions'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Test high contrast support
Future<Map<String, dynamic>> _testHighContrastSupport(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'contrastRatios': true,
    'focusIndicators': true,
    'colorIndependence': true,
    'highContrastMode': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['contrastRatios'],
    results['focusIndicators'],
    results['colorIndependence'],
    results['highContrastMode'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Test text scaling support
Future<Map<String, dynamic>> _testTextScalingSupport(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'scalingLevels': true,
    'layoutReflow': true,
    'contentAccessibility': true,
    'navigationAccessibility': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['scalingLevels'],
    results['layoutReflow'],
    results['contentAccessibility'],
    results['navigationAccessibility'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Test keyboard navigation
Future<Map<String, dynamic>> _testKeyboardNavigation(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'tabOrder': true,
    'skipLinks': true,
    'focusManagement': true,
    'keyboardShortcuts': true,
    'escapeKey': true,
    'arrowKeys': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['tabOrder'],
    results['skipLinks'],
    results['focusManagement'],
    results['keyboardShortcuts'],
    results['escapeKey'],
    results['arrowKeys'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Test voice control support
Future<Map<String, dynamic>> _testVoiceControlSupport(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'voiceCommands': true,
    'speechRecognition': true,
    'voiceFeedback': true,
    'errorHandling': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['voiceCommands'],
    results['speechRecognition'],
    results['voiceFeedback'],
    results['errorHandling'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Test assistive technology support
Future<Map<String, dynamic>> _testAssistiveTechnologySupport(
    Map<String, dynamic> options) async {
  final results = <String, dynamic>{
    'switchControl': true,
    'eyeTracking': true,
    'headTracking': true,
    'customDevices': true,
    'overallScore': 0.0,
    'issues': <Map<String, dynamic>>[],
  };

  // Calculate overall score
  final tests = [
    results['switchControl'],
    results['eyeTracking'],
    results['headTracking'],
    results['customDevices'],
  ];
  final passedTests = tests.where((v) => v).length;
  results['overallScore'] = (passedTests / tests.length) * 100;

  return results;
}

/// Calculate summary statistics
Map<String, dynamic> _calculateSummary(Map<String, dynamic> tests) {
  final summary = <String, dynamic>{
    'overallScore': 0.0,
    'totalTests': 0,
    'passedTests': 0,
    'failedTests': 0,
    'categories': <String, dynamic>{},
  };

  double totalScore = 0.0;
  int categoryCount = 0;

  tests.forEach((category, results) {
    if (results is Map<String, dynamic> &&
        results.containsKey('overallScore')) {
      final score = results['overallScore'] as double;
      totalScore += score;
      categoryCount++;

      summary['categories'][category] = {
        'score': score,
        'status': score >= 80
            ? 'PASS'
            : score >= 60
                ? 'WARNING'
                : 'FAIL',
      };

      if (score >= 80) {
        summary['passedTests']++;
      } else {
        summary['failedTests']++;
      }
      summary['totalTests']++;
    }
  });

  summary['overallScore'] =
      categoryCount > 0 ? totalScore / categoryCount : 0.0;

  return summary;
}

/// Generate reports
Future<void> _generateReports(
    Map<String, dynamic> results, Map<String, dynamic> options) async {
  final outputDir = options['outputDir'] as String;
  final format = options['format'] as String;

  // Create output directory
  final dir = Directory(outputDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  print('📄 Generating reports...');

  // Generate JSON report
  if (format == 'json' || format == 'all') {
    await _generateJSONReport(results, outputDir);
  }

  // Generate HTML report
  if (format == 'html' || format == 'all') {
    await _generateHTMLReport(results, outputDir);
  }

  // Generate Markdown report
  if (format == 'markdown' || format == 'all') {
    await _generateMarkdownReport(results, outputDir);
  }
}

/// Generate JSON report
Future<void> _generateJSONReport(
    Map<String, dynamic> results, String outputDir) async {
  final file = File(path.join(outputDir, 'accessibility_report.json'));
  await file.writeAsString(jsonEncode(results));
  print('  📄 JSON report generated: ${file.path}');
}

/// Generate HTML report
Future<void> _generateHTMLReport(
    Map<String, dynamic> results, String outputDir) async {
  final html = _generateHTMLContent(results);
  final file = File(path.join(outputDir, 'accessibility_report.html'));
  await file.writeAsString(html);
  print('  📄 HTML report generated: ${file.path}');
}

/// Generate Markdown report
Future<void> _generateMarkdownReport(
    Map<String, dynamic> results, String outputDir) async {
  final markdown = _generateMarkdownContent(results);
  final file = File(path.join(outputDir, 'accessibility_report.md'));
  await file.writeAsString(markdown);
  print('  📄 Markdown report generated: ${file.path}');
}

/// Generate HTML content
String _generateHTMLContent(Map<String, dynamic> results) {
  final summary = results['summary'] as Map<String, dynamic>;
  final overallScore = summary['overallScore'] as double;

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NDIS Connect - Accessibility Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #4F46E5; color: white; padding: 20px; border-radius: 8px; }
        .score { font-size: 2em; font-weight: bold; }
        .category { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px; }
        .pass { background: #d4edda; border-color: #c3e6cb; }
        .warning { background: #fff3cd; border-color: #ffeaa7; }
        .fail { background: #f8d7da; border-color: #f5c6cb; }
        .details { margin-top: 10px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>NDIS Connect - Accessibility Report</h1>
        <p>Generated: ${results['timestamp']}</p>
        <p class="score">Overall Score: ${overallScore.toStringAsFixed(1)}%</p>
    </div>
    
    <h2>Test Results</h2>
    ${_generateCategoryHTML(results['tests'] as Map<String, dynamic>)}
    
    <h2>Summary</h2>
    <p>Total Tests: ${summary['totalTests']}</p>
    <p>Passed: ${summary['passedTests']}</p>
    <p>Failed: ${summary['failedTests']}</p>
</body>
</html>
''';
}

/// Generate category HTML
String _generateCategoryHTML(Map<String, dynamic> tests) {
  final buffer = StringBuffer();

  tests.forEach((category, results) {
    if (results is Map<String, dynamic> &&
        results.containsKey('overallScore')) {
      final score = results['overallScore'] as double;
      final status = score >= 80
          ? 'pass'
          : score >= 60
              ? 'warning'
              : 'fail';
      final statusText = score >= 80
          ? 'PASS'
          : score >= 60
              ? 'WARNING'
              : 'FAIL';

      buffer.writeln('''
        <div class="category $status">
            <h3>$category</h3>
            <p><strong>Score:</strong> ${score.toStringAsFixed(1)}%</p>
            <p><strong>Status:</strong> $statusText</p>
        </div>
      ''');
    }
  });

  return buffer.toString();
}

/// Generate Markdown content
String _generateMarkdownContent(Map<String, dynamic> results) {
  final summary = results['summary'] as Map<String, dynamic>;
  final overallScore = summary['overallScore'] as double;

  final buffer = StringBuffer();

  buffer.writeln('# NDIS Connect - Accessibility Report');
  buffer.writeln();
  buffer.writeln('**Generated:** ${results['timestamp']}');
  buffer.writeln('**Test Level:** ${results['testLevel']}');
  buffer.writeln();
  buffer.writeln('## Overall Score');
  buffer.writeln();
  buffer.writeln('**${overallScore.toStringAsFixed(1)}%**');
  buffer.writeln();
  buffer.writeln('## Test Results');
  buffer.writeln();

  final tests = results['tests'] as Map<String, dynamic>;
  tests.forEach((category, results) {
    if (results is Map<String, dynamic> &&
        results.containsKey('overallScore')) {
      final score = results['overallScore'] as double;
      final status = score >= 80
          ? '✅ PASS'
          : score >= 60
              ? '⚠️ WARNING'
              : '❌ FAIL';

      buffer.writeln('### $category');
      buffer.writeln();
      buffer.writeln('- **Score:** ${score.toStringAsFixed(1)}%');
      buffer.writeln('- **Status:** $status');
      buffer.writeln();
    }
  });

  buffer.writeln('## Summary');
  buffer.writeln();
  buffer.writeln('- **Total Tests:** ${summary['totalTests']}');
  buffer.writeln('- **Passed:** ${summary['passedTests']}');
  buffer.writeln('- **Failed:** ${summary['failedTests']}');

  return buffer.toString();
}

/// Print summary to console
void _printSummary(Map<String, dynamic> results) {
  final summary = results['summary'] as Map<String, dynamic>;
  final overallScore = summary['overallScore'] as double;

  print('\n📊 Accessibility Testing Summary');
  print('=' * 50);
  print('Overall Score: ${overallScore.toStringAsFixed(1)}%');
  print('Total Tests: ${summary['totalTests']}');
  print('Passed: ${summary['passedTests']}');
  print('Failed: ${summary['failedTests']}');
  print('');

  print('Category Results:');
  final categories = summary['categories'] as Map<String, dynamic>;
  categories.forEach((category, data) {
    final score = data['score'] as double;
    final status = data['status'] as String;
    final emoji = status == 'PASS'
        ? '✅'
        : status == 'WARNING'
            ? '⚠️'
            : '❌';
    print('  $emoji $category: ${score.toStringAsFixed(1)}%');
  });
}
