# PR: Fix Android build: align Gradle/AGP/Kotlin + resolve dependency conflicts

## Root Cause
The build was failing at `:app:checkDebugDuplicateClasses` task due to duplicate class `com.google.firebase.iid.FirebaseInstanceIdReceiver` found in both firebase-iid:20.1.5 and firebase-messaging:25.0.0 modules. This occurred because firebase-iid was deprecated and its functionality was merged into firebase-messaging, but both libraries were being included transitively.

## Changes
- **Modified file**: `android/app/build.gradle`
- **Change**: Added global configuration exclusion for deprecated firebase-iid module
- **Lines added**: 141-144 (after dependencies block)
```gradle
// Exclude deprecated firebase-iid to fix duplicate class issue
configurations.all {
    exclude group: 'com.google.firebase', module: 'firebase-iid'
}
```

## Verification
### Commands run:
```bash
cd android
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
.\gradlew.bat :app:assembleDebug
```

### Exit status: **SUCCESS** ✅
- Build completed successfully in 8m 13s
- 751 actionable tasks: 154 executed, 597 up-to-date
- No duplicate class errors

### CI Note
The fix should work in CI environments as it only excludes a deprecated dependency and doesn't change any versions or require special configuration.

## Risk & Rollback
### Potential Risks:
- None identified - firebase-iid functionality is fully replaced by firebase-messaging
- The exclusion only removes duplicate deprecated code

### Rollback Instructions:
To revert this change, run:
```bash
git revert <commit-hash>
```
This will remove the 4-line exclusion configuration from android/app/build.gradle.

## Build Output Summary
```
BUILD SUCCESSFUL in 8m 13s
751 actionable tasks: 154 executed, 597 up-to-date
```

### Non-breaking warnings observed:
1. BuildConfig deprecation warning (can be addressed in future)
2. compileSdk 36 exceeds AGP 8.6.0 tested range (still works)
3. Java 8 source/target deprecation (non-critical)
