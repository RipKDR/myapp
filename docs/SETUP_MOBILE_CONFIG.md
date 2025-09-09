NDIS Connect – Mobile Configuration Setup

This guide gets the app running on Android and iOS by configuring Firebase, Android resources, Google Maps keys, and signing.

1) Firebase (Critical)
- Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Configure: `powershell -ExecutionPolicy Bypass -File scripts/setup_firebase.ps1 -Platforms ios,android`
- Sign in when prompted and choose the Firebase project.
- Results:
  - Generates `lib/firebase_options.dart` (replace stub)
  - Creates `android/app/google-services.json`
 - Creates `ios/Runner/GoogleService-Info.plist`
- Notes:
  - `lib/firebase_options.dart` is now committed so new devs can run without local setup.
  - App will run without Firebase, but features depending on it will be disabled.

Verification:
- Run `dart scripts/verify_mobile_config.dart` to validate files and keys.
- In CI, a workflow `.github/workflows/verify-mobile-config.yml` runs a soft check.

2) Android Resources (Fixed)
- Added required files:
  - `android/app/src/main/res/values/colors.xml` (includes `notification_color`)
  - `android/app/src/main/res/values/strings.xml`
  - `android/app/src/main/res/values/styles.xml` (LaunchTheme, NormalTheme)
 - `android/app/src/main/res/drawable/ic_notification.xml`
 - `android/app/src/main/res/drawable/launch_background.xml`
- These resolve build errors for notification icon/color and launch theme.

3) Google Maps API Keys
- Android:
  - Manifest uses placeholder `${GOOGLE_MAPS_API_KEY}`.
  - Provide the key via environment or Gradle property:
    - Temporary env: `setx GOOGLE_MAPS_API_KEY "YOUR_KEY"` then restart shell.
    - Or add to `~/.gradle/gradle.properties`: `GOOGLE_MAPS_API_KEY=YOUR_KEY`.
- iOS:
  - Set key in `ios/Runner/Info.plist` under `<key>GMSApiKey</key>`.
  - Alternatively, set in Xcode Build Settings using a user-defined setting and Info.plist substitution.

4) App Signing (Release Builds)
- We refactored signing to load from `key.properties` if present.
- Create a keystore:
  - `keytool -genkey -v -keystore android/app/ndis-connect-release.keystore -alias ndis-connect-release -keyalg RSA -keysize 2048 -validity 10000`
- Create `key.properties` (do not commit):
  - See `key.properties.example` for required keys.
- The build will fall back to placeholder values if `key.properties` is missing (not suitable for release).

5) Build & Run
- Android Debug: `flutter run -d android`
- Android Release (once signing is set): `flutter build apk --release`
- iOS (on macOS): `cd ios && pod install && cd ..` then `flutter run -d ios`

6) Checklist
- Replace all placeholder keys:
  - Firebase: use FlutterFire-generated files and options.
  - Maps: Android `${GOOGLE_MAPS_API_KEY}` and iOS `GMSApiKey`.
- Verify notifications:
  - Default icon: `@drawable/ic_notification`
  - Default color: `@color/notification_color`
- Confirm `.gitignore` prevents committing secrets:
  - google-services.json, iOS plist, keystore, key.properties.
