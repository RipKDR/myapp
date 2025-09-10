# NDIS Connect

A modern, accessible Flutter application for NDIS participants and providers to manage their plans, budgets, and services.

## Features

- **Role-based Access**: Separate experiences for participants and providers
- **Budget Management**: Track spending across NDIS plan categories
- **Claims Processing**: Submit and track reimbursement claims
- **Service Discovery**: Find and contact NDIS service providers
- **Secure Messaging**: Communicate with providers and support circle
- **Calendar Integration**: Manage appointments and schedules
- **Support Circle**: Manage family, carers, and support network
- **Accessibility**: WCAG 2.2 AA compliant with high contrast and reduced motion support

## Design & Run

### Prerequisites
- Flutter 3.24.0 or higher
- Android SDK 36
- Android Studio or VS Code with Flutter extension

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd ndis-connect

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Development
```bash
# Run in debug mode
flutter run --debug

# Run on specific device
flutter run -d <device-id>

# Hot reload is enabled by default
```

## Build APK

### Debug Build
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## Signing (Release)

### Generate Keystore
```bash
keytool -genkeypair -v -keystore release-keystore.jks -alias ndis-connect-key -keyalg RSA -keysize 2048 -validity 10000 -storetype JKS
```

### Configure Signing
1. Create `android/key.properties` (git-ignored):
```properties
storeFile=../release-keystore.jks
storePassword=CHANGE_ME
keyAlias=ndis-connect-key
keyPassword=CHANGE_ME
```

2. The signing configuration is already set up in `android/app/build.gradle`

## Design System

### Tokens
Edit design tokens in `lib/ui/theme/tokens/`:
- `colors.dart` - Color palette and semantic colors
- `spacing.dart` - Spacing scale and component spacing
- `typography.dart` - Font families and text styles
- `radius.dart` - Border radius values
- `shadows.dart` - Elevation and shadow definitions
- `motion.dart` - Animation durations and easing

### Components
Reusable components in `lib/ui/components/`:
- `app_scaffold.dart` - Consistent layout structure
- `buttons.dart` - Primary, secondary, and text buttons
- `cards.dart` - Budget, appointment, and general cards
- `forms.dart` - Enhanced form fields
- `navigation.dart` - Bottom navigation and tab bars
- `empty_states.dart` - Loading, error, and empty states

## Architecture

### Project Structure
```
lib/
├── app/
│   └── router.dart                 # Navigation configuration
├── controllers/                    # State management
├── features/                       # Feature-based organization
│   ├── onboarding/
│   ├── dashboard/
│   ├── budget/
│   ├── claims/
│   ├── services/
│   ├── messages/
│   ├── support/
│   ├── calendar/
│   ├── settings/
│   └── dev/
├── ui/                            # Design system
│   ├── theme/tokens/              # Design tokens
│   └── components/                # Reusable components
├── services/                      # External services
├── repositories/                  # Data access layer
├── models/                        # Data models
└── utils/                         # Utilities
```

### Navigation
- **go_router**: Modern declarative routing
- **Deep Links**: All routes accessible via URL
- **Route Guards**: Role-based access control

### State Management
- **Provider**: Global state management
- **Local State**: StatefulWidget for component state

## Accessibility

### WCAG 2.2 AA Compliance
- **Color Contrast**: Minimum 4.5:1 contrast ratio
- **Touch Targets**: 44px minimum touch target size
- **Text Scaling**: Support for 80%-200% text scaling
- **Screen Readers**: Semantic labels and descriptions
- **Keyboard Navigation**: Logical focus order
- **Reduced Motion**: Respects user motion preferences

### High Contrast Mode
- Enhanced contrast ratios (7:1)
- Bolder borders and shadows
- Increased font weights
- Alternative color schemes

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Golden Tests
```bash
flutter test --update-goldens
```

### Integration Tests
```bash
flutter test integration_test/
```

## Troubleshooting

### Build Issues
- **Gradle Sync**: Run `flutter clean && flutter pub get`
- **Android SDK**: Ensure Android SDK 36 is installed
- **Java Version**: Use Java 17 (bundled with Android Studio)

### Runtime Issues
- **Hot Reload**: Restart the app if hot reload fails
- **Device Connection**: Check `flutter devices` for connected devices
- **Permissions**: Ensure required permissions are granted

### Common Errors
- **Missing Classes**: Check ProGuard rules in `android/app/proguard-rules.pro`
- **Signing Issues**: Verify keystore configuration in `android/key.properties`
- **Dependency Conflicts**: Run `flutter pub deps` to check dependency tree

## Contributing

1. Follow the existing code style and architecture
2. Add tests for new features
3. Update documentation for API changes
4. Ensure accessibility compliance
5. Test on multiple devices and screen sizes

## License

This project is licensed under the MIT License - see the LICENSE file for details.