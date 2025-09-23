# 📱 NDIS Connect - Mobile App Deployment Guide

## 🎯 Overview

This guide provides comprehensive instructions for deploying the NDIS Connect Flutter app to Android and iOS app stores.

## 📋 Prerequisites

### Development Environment
- ✅ Flutter SDK (3.24.0 or higher)
- ✅ Android Studio with Android SDK
- ✅ Xcode (for iOS development)
- ✅ Git for version control
- ✅ Firebase project configured

### Required Accounts
- ✅ Google Play Console account (for Android)
- ✅ Apple Developer account (for iOS)
- ✅ Firebase project with proper configuration

## 🤖 Android Deployment

### 1. Build Configuration

The app is configured with:
- **Application ID**: `com.ndisconnect.app`
- **Target SDK**: 34 (Android 14)
- **Min SDK**: 21 (Android 5.0)
- **ProGuard**: Enabled for release builds
- **MultiDex**: Enabled for large app support

### 2. Signing Configuration

Create a `key.properties` file in the `android/` directory:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore/ndis_connect_keystore.jks
```

### 3. Generate Release APK

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### 4. Google Play Store Upload

1. **Create App Listing**:
   - App name: "NDIS Connect"
   - Short description: "Accessible companion for NDIS participants and providers"
   - Full description: Use content from `store_assets/google_play_description_v2.md`

2. **Upload APK/AAB**:
   - Upload the generated `.aab` file from `build/app/outputs/bundle/release/`
   - Complete store listing with screenshots and metadata

3. **Content Rating**: Complete the content rating questionnaire

4. **Pricing & Distribution**: Set as free app, select target countries

5. **App Content**: Complete privacy policy and terms of service

## 🍎 iOS Deployment

### 1. Xcode Configuration

1. **Open Project**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Bundle Identifier**:
   - Set to `com.ndisconnect.app`
   - Ensure it matches your Apple Developer account

3. **Configure Signing**:
   - Select your development team
   - Choose appropriate provisioning profile

### 2. Build iOS App

```bash
# Build iOS app
flutter build ios --release

# Build for App Store
flutter build ipa --release
```

### 3. App Store Connect Upload

1. **Create App Record**:
   - App name: "NDIS Connect"
   - Bundle ID: `com.ndisconnect.app`
   - SKU: `ndis-connect-ios`

2. **Upload Build**:
   - Use Xcode Organizer or `flutter build ipa`
   - Upload to App Store Connect

3. **App Information**:
   - Use content from `store_assets/app_store_description_v2.md`
   - Add screenshots and app previews
   - Set age rating and content descriptions

## 🔧 Build Scripts

### Windows (PowerShell)
```powershell
# Run tests
.\scripts\run_tests.ps1

# Build Android
flutter build appbundle --release

# Build iOS (requires macOS)
flutter build ipa --release
```

### macOS/Linux
```bash
# Run tests
./scripts/run_tests.sh

# Build Android
flutter build appbundle --release

# Build iOS
flutter build ipa --release
```

## 📊 Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (unit, widget, integration)
- [ ] Code coverage above 80%
- [ ] Linting issues resolved
- [ ] Security audit passed
- [ ] Performance benchmarks met

### App Configuration
- [ ] App icons configured for all platforms
- [ ] Splash screens implemented
- [ ] Deep linking configured
- [ ] Push notifications tested
- [ ] Offline functionality verified

### Store Assets
- [ ] App screenshots (all required sizes)
- [ ] App preview videos (iOS)
- [ ] Feature graphic (Android)
- [ ] App descriptions in multiple languages
- [ ] Privacy policy and terms of service

### Firebase Configuration
- [ ] Production Firebase project configured
- [ ] Analytics enabled
- [ ] Crashlytics configured
- [ ] Remote config set up
- [ ] Authentication providers configured

## 🚀 Deployment Steps

### 1. Pre-Release Testing
```bash
# Run comprehensive tests
flutter test
flutter test integration_test/

# Test on physical devices
flutter run --release
```

### 2. Build Release Versions
```bash
# Android
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64

# iOS
flutter build ipa --release
```

### 3. Upload to Stores
- **Android**: Upload AAB to Google Play Console
- **iOS**: Upload IPA to App Store Connect

### 4. Store Review Process
- **Android**: Usually 1-3 days
- **iOS**: Usually 1-7 days

## 🔍 Post-Deployment Monitoring

### Analytics Setup
- Monitor user engagement with Firebase Analytics
- Track app performance with Firebase Performance
- Monitor crashes with Firebase Crashlytics

### Key Metrics to Monitor
- App installs and uninstalls
- User retention rates
- Crash-free sessions
- App performance metrics
- User feedback and ratings

## 🛠️ Troubleshooting

### Common Android Issues
- **Build failures**: Check Android SDK version compatibility
- **Signing issues**: Verify keystore configuration
- **Size issues**: Enable ProGuard and resource shrinking

### Common iOS Issues
- **Build failures**: Check Xcode version and iOS deployment target
- **Signing issues**: Verify Apple Developer account and certificates
- **App Store rejection**: Review Apple's App Store Review Guidelines

## 📞 Support

For deployment issues:
1. Check Flutter documentation
2. Review platform-specific guides
3. Contact Firebase support for backend issues
4. Check app store review guidelines

## 🎉 Success Criteria

Your app is ready for production when:
- ✅ All tests pass with >80% coverage
- ✅ No critical security vulnerabilities
- ✅ Performance meets target benchmarks
- ✅ App store assets are complete
- ✅ Firebase configuration is production-ready
- ✅ Both Android and iOS builds are successful

---

**Next Steps**: After successful deployment, focus on user feedback, performance monitoring, and iterative improvements based on real-world usage data.
