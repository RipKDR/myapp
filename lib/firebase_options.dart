// Runtime-configurable Firebase options using --dart-define.
// Replace with FlutterFire generated file for production builds.
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Read from environment to avoid hardcoded placeholders.
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
    const appId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    );
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: '');
    const measurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: '');

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }
}

