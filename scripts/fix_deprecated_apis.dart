#!/usr/bin/env dart

import 'dart:io';

/// Script to fix deprecated Flutter APIs
/// This script replaces deprecated withOpacity calls with withValues
void main() async {
  print('🔧 Starting deprecated API fixes...');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ lib directory not found');
    exit(1);
  }

  int totalFiles = 0;
  int fixedFiles = 0;
  int totalReplacements = 0;

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      totalFiles++;
      final content = await entity.readAsString();
      final originalContent = content;

      // Fix withOpacity deprecation
      final fixedContent = _fixWithOpacity(content);

      if (fixedContent != originalContent) {
        await entity.writeAsString(fixedContent);
        fixedFiles++;
        final replacements = _countReplacements(originalContent, fixedContent);
        totalReplacements += replacements;
        print('✅ Fixed ${entity.path} ($replacements replacements)');
      }
    }
  }

  print('\n📊 Summary:');
  print('   Total files processed: $totalFiles');
  print('   Files fixed: $fixedFiles');
  print('   Total replacements: $totalReplacements');
  print('🎉 Deprecated API fixes completed!');
}

String _fixWithOpacity(final String content) {
  // Pattern to match withOpacity calls
  final withOpacityPattern = RegExp(
    r'\.withOpacity\(([^)]+)\)',
    multiLine: true,
  );

  return content.replaceAllMapped(withOpacityPattern, (final match) {
    final opacityValue = match.group(1);
    return '.withValues(alpha: $opacityValue)';
  });
}

int _countReplacements(final String original, final String fixed) {
  final originalMatches =
      RegExp(r'\.withOpacity\(').allMatches(original).length;
  final fixedMatches = RegExp(r'\.withValues\(').allMatches(fixed).length;
  return fixedMatches -
      (originalMatches -
          RegExp(r'\.withOpacity\(').allMatches(original).length);
}
