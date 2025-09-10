#!/usr/bin/env dart

import 'dart:io';

/// Update Firebase dependencies to latest stable versions from FlutterFire
void main() async {
  print('🔥 Updating Firebase dependencies to latest stable versions...');

  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('❌ pubspec.yaml not found');
    return;
  }

  String content = await file.readAsString();

  // Update Firebase dependencies to latest stable versions
  // Based on FlutterFire repository stable releases
  final firebaseUpdates = {
    'firebase_core: ^3.6.0': 'firebase_core: ^3.15.2',
    'firebase_auth: ^5.3.1': 'firebase_auth: ^5.7.0',
    'cloud_firestore: ^5.4.3': 'cloud_firestore: ^5.6.12',
    'firebase_messaging: ^15.1.3': 'firebase_messaging: ^15.2.10',
    'firebase_analytics: ^11.3.3': 'firebase_analytics: ^11.6.0',
    'firebase_crashlytics: ^4.1.3': 'firebase_crashlytics: ^4.3.10',
  };

  for (final entry in firebaseUpdates.entries) {
    if (content.contains(entry.key)) {
      content = content.replaceAll(entry.key, entry.value);
      print('✅ Updated ${entry.key.split(":")[0]}');
    }
  }

  // Also update other dependencies to compatible versions
  final otherUpdates = {
    'geolocator: ^13.0.1': 'geolocator: ^13.0.4',
    'permission_handler: ^11.3.1': 'permission_handler: ^11.4.0',
    'workmanager: ^0.5.2': 'workmanager: ^0.5.2',
    'flutter_local_notifications: ^18.0.1':
        'flutter_local_notifications: ^18.0.1',
  };

  for (final entry in otherUpdates.entries) {
    if (content.contains(entry.key)) {
      content = content.replaceAll(entry.key, entry.value);
      print('✅ Updated ${entry.key.split(":")[0]}');
    }
  }

  await file.writeAsString(content);
  print('🎉 Firebase dependencies updated successfully!');
  print('📦 Run "flutter pub get" to install the updated dependencies.');
}
