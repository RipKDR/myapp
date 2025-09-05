#!/bin/bash

# NDIS Connect - Production Deployment Script
# This script handles the complete deployment process for production

set -e  # Exit on any error

echo "🚀 NDIS Connect - Production Deployment"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    print_success "All dependencies are installed"
}

# Validate environment
validate_environment() {
    print_status "Validating environment..."
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Are you in the project root?"
        exit 1
    fi
    
    # Check if Firebase is configured
    if [ ! -f "lib/firebase_options.dart" ]; then
        print_error "Firebase configuration file not found"
        exit 1
    fi
    
    # Check for placeholder values
    if grep -q "REPLACE_ME" lib/firebase_options.dart; then
        print_error "Firebase configuration contains placeholder values"
        exit 1
    fi
    
    print_success "Environment validation passed"
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Run unit tests
    flutter test
    
    # Run integration tests if they exist
    if [ -d "integration_test" ]; then
        flutter drive --target=integration_test/app_test.dart
    fi
    
    print_success "All tests passed"
}

# Build for production
build_production() {
    print_status "Building for production..."
    
    # Clean previous builds
    flutter clean
    flutter pub get
    
    # Build Android
    print_status "Building Android APK..."
    flutter build apk --release --target-platform android-arm64
    
    # Build Android App Bundle
    print_status "Building Android App Bundle..."
    flutter build appbundle --release
    
    # Build iOS (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Building iOS..."
        flutter build ios --release --no-codesign
    else
        print_warning "Skipping iOS build (not on macOS)"
    fi
    
    print_success "Production builds completed"
}

# Deploy Firebase rules and functions
deploy_firebase() {
    print_status "Deploying Firebase configuration..."
    
    # Deploy Firestore rules
    firebase deploy --only firestore:rules
    
    # Deploy Firebase functions if they exist
    if [ -d "functions" ]; then
        firebase deploy --only functions
    fi
    
    print_success "Firebase deployment completed"
}

# Generate app icons
generate_icons() {
    print_status "Generating app icons..."
    
    # Check if flutter_launcher_icons is available
    if flutter pub deps | grep -q "flutter_launcher_icons"; then
        flutter pub run flutter_launcher_icons:main
        print_success "App icons generated"
    else
        print_warning "flutter_launcher_icons not configured, skipping icon generation"
    fi
}

# Create release notes
create_release_notes() {
    print_status "Creating release notes..."
    
    # Get version from pubspec.yaml
    VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
    
    # Create release notes file
    cat > RELEASE_NOTES.md << EOF
# NDIS Connect v$VERSION

## 🎉 Production Release

### New Features
- Complete authentication system with role-based access
- Real-time appointment and budget management
- WCAG 2.2 AA accessibility compliance
- Offline-first design with data synchronization
- Comprehensive error handling and user feedback

### Improvements
- Enhanced security with Firebase security rules
- Improved performance and caching
- Better user experience with accessibility features
- Comprehensive testing and validation

### Technical Details
- Flutter SDK: $(flutter --version | head -n 1)
- Build Date: $(date)
- Target Platforms: Android, iOS
- Firebase Integration: Complete
- Accessibility: WCAG 2.2 AA Compliant

### Installation
1. Download from Google Play Store or Apple App Store
2. Sign up with email or continue as guest
3. Select your role (Participant or Provider)
4. Start managing your NDIS journey!

### Support
- Email: support@ndisconnect.app
- Help Center: https://help.ndisconnect.app
- Community: https://community.ndisconnect.app

---
*Built with ❤️ for the NDIS community*
EOF
    
    print_success "Release notes created"
}

# Main deployment function
main() {
    echo "Starting deployment process..."
    
    # Check dependencies
    check_dependencies
    
    # Validate environment
    validate_environment
    
    # Run tests
    run_tests
    
    # Generate icons
    generate_icons
    
    # Build for production
    build_production
    
    # Deploy Firebase
    deploy_firebase
    
    # Create release notes
    create_release_notes
    
    print_success "🎉 Deployment completed successfully!"
    print_status "Next steps:"
    echo "  1. Upload APK/AAB to Google Play Console"
    echo "  2. Upload IPA to App Store Connect"
    echo "  3. Submit for review"
    echo "  4. Monitor deployment with Firebase Console"
    echo "  5. Set up monitoring and analytics"
    
    print_warning "Remember to:"
    echo "  - Update version numbers for next release"
    echo "  - Test on real devices before submission"
    echo "  - Monitor crash reports and user feedback"
    echo "  - Keep Firebase security rules updated"
}

# Run main function
main "$@"
