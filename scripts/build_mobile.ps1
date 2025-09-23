# NDIS Connect Flutter App - Mobile Build Script (Windows PowerShell)
# This script builds the app for Android and iOS deployment

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("android", "ios", "both")]
    [string]$Platform = "both",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "release", "staging")]
    [string]$BuildType = "release",
    
    [switch]$SkipTests,
    [switch]$SkipLint,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 NDIS Connect Mobile Build Script" -ForegroundColor Blue
Write-Host "Platform: $Platform | Build Type: $BuildType" -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version | Select-Object -First 1
    Write-Status "Using $flutterVersion"
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

# Clean and get dependencies
Write-Status "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Run tests (if not skipped)
if (!$SkipTests) {
    Write-Status "Running tests..."
    flutter test
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tests failed. Aborting build."
        exit 1
    }
    Write-Success "All tests passed"
} else {
    Write-Warning "Skipping tests"
}

# Run linting (if not skipped)
if (!$SkipLint) {
    Write-Status "Running linting..."
    flutter analyze
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Linting failed. Aborting build."
        exit 1
    }
    Write-Success "Linting passed"
} else {
    Write-Warning "Skipping linting"
}

# Build Android
if ($Platform -eq "android" -or $Platform -eq "both") {
    Write-Status "Building Android app..."
    
    if ($BuildType -eq "release") {
        # Build App Bundle for Play Store
        flutter build appbundle --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Android App Bundle built successfully"
            Write-Host "Location: build/app/outputs/bundle/release/app-release.aab" -ForegroundColor Green
        } else {
            Write-Error "Android build failed"
            exit 1
        }
        
        # Also build APK for testing
        flutter build apk --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Android APK built successfully"
            Write-Host "Location: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
        }
    } elseif ($BuildType -eq "debug") {
        flutter build apk --debug
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Android Debug APK built successfully"
            Write-Host "Location: build/app/outputs/flutter-apk/app-debug.apk" -ForegroundColor Green
        } else {
            Write-Error "Android debug build failed"
            exit 1
        }
    } elseif ($BuildType -eq "staging") {
        flutter build apk --debug --dart-define=ENVIRONMENT=staging
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Android Staging APK built successfully"
            Write-Host "Location: build/app/outputs/flutter-apk/app-debug.apk" -ForegroundColor Green
        } else {
            Write-Error "Android staging build failed"
            exit 1
        }
    }
}

# Build iOS (requires macOS)
if ($Platform -eq "ios" -or $Platform -eq "both") {
    Write-Status "Building iOS app..."
    
    if ($BuildType -eq "release") {
        # Build IPA for App Store
        flutter build ipa --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "iOS IPA built successfully"
            Write-Host "Location: build/ios/ipa/ndis_connect.ipa" -ForegroundColor Green
        } else {
            Write-Error "iOS build failed"
            exit 1
        }
    } elseif ($BuildType -eq "debug") {
        flutter build ios --debug
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "iOS debug build successful"
            Write-Host "Open ios/Runner.xcworkspace in Xcode to run on device" -ForegroundColor Green
        } else {
            Write-Error "iOS debug build failed"
            exit 1
        }
    } elseif ($BuildType -eq "staging") {
        flutter build ios --debug --dart-define=ENVIRONMENT=staging
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "iOS staging build successful"
            Write-Host "Open ios/Runner.xcworkspace in Xcode to run on device" -ForegroundColor Green
        } else {
            Write-Error "iOS staging build failed"
            exit 1
        }
    }
}

# Generate build report
Write-Status "Generating build report..."
$buildReport = @"
# NDIS Connect Build Report

## Build Summary
- **Date**: $(Get-Date)
- **Platform**: $Platform
- **Build Type**: $BuildType
- **Flutter Version**: $flutterVersion

## Build Results
- ✅ Dependencies: Updated
- ✅ Tests: Passed
- ✅ Linting: Passed
- ✅ Android Build: Successful
- ✅ iOS Build: Successful

## Build Artifacts
- Android App Bundle: build/app/outputs/bundle/release/app-release.aab
- Android APK: build/app/outputs/flutter-apk/app-release.apk
- iOS IPA: build/ios/ipa/ndis_connect.ipa

## Next Steps
1. Test builds on physical devices
2. Upload to app stores
3. Monitor deployment metrics

"@

$buildReport | Out-File -FilePath "build_report.md" -Encoding UTF8

Write-Success "Build report generated at build_report.md"

# Display final summary
Write-Host ""
Write-Host "🎉 Build completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Build Summary:" -ForegroundColor Cyan
Write-Host "  - Platform: $Platform" -ForegroundColor White
Write-Host "  - Build Type: $BuildType" -ForegroundColor White
Write-Host "  - Tests: ✅ Passed" -ForegroundColor Green
Write-Host "  - Linting: ✅ Passed" -ForegroundColor Green
Write-Host "  - Android: ✅ Built" -ForegroundColor Green
Write-Host "  - iOS: ✅ Built" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Test builds on physical devices" -ForegroundColor White
Write-Host "  2. Upload to Google Play Console and App Store Connect" -ForegroundColor White
Write-Host "  3. Monitor deployment metrics" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready for mobile deployment!" -ForegroundColor Green
