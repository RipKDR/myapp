#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Verifies that required mobile configs are present:
/// - Firebase files for Android/iOS
/// - FlutterFire options generated
/// - Google Maps API keys configured
///
/// Usage:
///   dart scripts/verify_mobile_config.dart [--soft]
///   --soft: treat missing Maps key as warning (useful in CI where secrets are absent)
void main(List<String> args) {
  final soft = args.contains('--soft');
  final issues = <String>[];
  final warnings = <String>[];

  // 1) Firebase config files
  final androidFirebase = File('android/app/google-services.json');
  final iosFirebase = File('ios/Runner/GoogleService-Info.plist');
  if (!androidFirebase.existsSync()) {
    issues.add('Missing android/app/google-services.json');
  }
  if (!iosFirebase.existsSync()) {
    issues.add('Missing ios/Runner/GoogleService-Info.plist');
  }

  // 2) FlutterFire generated options
  final optionsFile = File('lib/firebase_options.dart');
  if (!optionsFile.existsSync()) {
    issues.add('Missing lib/firebase_options.dart (run flutterfire configure)');
  } else {
    final contents = optionsFile.readAsStringSync();
    if (contents.contains('REPLACE_ME')) {
      issues.add('lib/firebase_options.dart still contains placeholders');
    }
  }

  // 3) Android Maps key placeholder & env
  final androidManifest = File('android/app/src/main/AndroidManifest.xml');
  if (androidManifest.existsSync()) {
    final manifest = androidManifest.readAsStringSync();
    if (!manifest.contains('com.google.android.geo.API_KEY')) {
      warnings.add('AndroidManifest.xml missing Google Maps API_KEY meta-data');
    } else if (!manifest.contains(r'${AIzaSyDwG_imrSuzCYuSBgU1v19XjoTyGfE6yds}')) {
      warnings.add('AndroidManifest.xml Maps meta-data not using placeholder \${AIzaSyDwG_imrSuzCYuSBgU1v19XjoTyGfE6yds}');
    }
  }

  final mapsEnv = Platform.environment['AIzaSyDwG_imrSuzCYuSBgU1v19XjoTyGfE6yds'];
  if (mapsEnv == null || mapsEnv.trim().isEmpty) {
    final msg = 'Environment variable GOOGLE_MAPS_API_KEY not set';
    if (soft) {
      warnings.add(msg);
    } else {
      issues.add(msg);
    }
  }

  // 4) iOS Maps key value is not a placeholder
  final infoPlist = File('ios/Runner/Info.plist');
  if (infoPlist.existsSync()) {
    final plist = infoPlist.readAsStringSync();
    if (plist.contains('<key>GMSApiKey</key>') &&
        plist.contains('<string>YOUR_GOOGLE_MAPS_API_KEY</string>')) {
      issues.add('iOS Info.plist GMSApiKey still set to YOUR_GOOGLE_MAPS_API_KEY');
    }
  }

  // 5) Android notification resources sanity check
  final notifIcon = File('android/app/src/main/res/drawable/ic_notification.xml');
  final notifColor = File('android/app/src/main/res/values/colors.xml');
  if (!notifIcon.existsSync()) warnings.add('Missing ic_notification drawable for FCM default icon');
  if (!notifColor.existsSync()) warnings.add('Missing colors.xml (notification_color)');

  // Report
  if (warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final w in warnings) {
      stdout.writeln('  - $w');
    }
    stdout.writeln('');
  }

  if (issues.isNotEmpty) {
    stdout.writeln('Blocking issues:');
    for (final i in issues) {
      stdout.writeln('  - $i');
    }
    stdout.writeln('');
  }

  final ok = issues.isEmpty;
  final result = {
    'ok': ok,
    'issues': issues,
    'warnings': warnings,
  };
  stdout.writeln(jsonEncode(result));
  if (!ok) exit(1);
}

