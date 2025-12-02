# Ballot Access Pro!

<div align="center">
  <img src="assets/images/logo_main.png" alt="Ballot Access Pro Logo" width="200"/>
  
  [![Flutter Version](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)]()
</div>

## 📱 Overview

Ballet Access Pro is a comprehensive mobile application designed to streamline and manage ballot access processes for political campaigns and petition drives. Built with Flutter, it provides field workers (petitioners) with powerful tools for territory management, signature collection, and real-time coordination with campaign headquarters.

### Key Capabilities

- **Territory Management**: Visual map-based assignment and tracking of canvassing territories
- **House Visits**: Pin-drop interface for marking visited houses with detailed visit logs
- **Audio Recording**: Built-in recording capabilities for documenting interactions
- **Real-time Sync**: WebSocket-based live updates between field workers and administrators
- **Offline Support**: Fully functional offline mode with automatic sync when connectivity returns
- **Work Session Tracking**: Time tracking and productivity metrics for petitioners
- **Push Notifications**: Firebase Cloud Messaging for real-time alerts and updates

## ✨ Features

### 🗺️ Map & Location
- Interactive Google Maps integration with custom styling
- Real-time GPS tracking and location services
- Territory boundaries visualization
- House marker placement and management
- Geocoding and reverse geocoding for address lookup
- External map app integration (Google Maps, Apple Maps, etc.)

### 🔐 Authentication & Security
- Secure user authentication with JWT tokens
- Email verification system
- Phone number validation with international support
- Encrypted secure storage for sensitive data
- Role-based access control (petitioner/admin)

### 📡 Real-time Communication
- WebSocket integration for live updates
- Push notifications via Firebase Cloud Messaging
- Background message handling
- Automatic reconnection on network restore

### 💾 Data Management
- SQLite local database for offline storage
- SharedPreferences for app settings
- Secure storage for authentication tokens
- Automatic data synchronization
- Image capture and storage

### 🎨 User Interface
- Responsive design with ScreenUtil
- Custom SVG icons and assets
- Material Design principles
- Shimmer loading effects
- Toast notifications
- Custom fonts (Marcellus)
- Connection status indicators

### 🎙️ Audio Features
- Voice recording during house visits
- Audio playback with controls
- Recording caching and management
- Multiple audio format support

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: v3.0.0+ (Cross-platform mobile framework)
- **Dart**: v3.0.0+ (Programming language)

### Architecture & State Management
- **flutter_bloc** ^8.1.4 - Reactive state management
- **bloc** ^8.1.2 - Business logic components
- **equatable** ^2.0.5 - Value equality for state management
- **get_it** ^7.6.4 - Service locator pattern for dependency injection

### Storage & Persistence
- **sqflite** ^2.3.0 - SQLite database for local data
- **shared_preferences** ^2.2.2 - Key-value storage
- **flutter_secure_storage** ^9.0.0 - Encrypted storage for sensitive data
- **path_provider** ^2.1.5 - File system path access

### Networking & API
- **dio** ^5.4.0 - HTTP client with interceptors
- **http** ^1.1.0 - HTTP utilities
- **socket_io_client** ^2.0.3+1 - Real-time WebSocket communication
- **connectivity_plus** ^5.0.2 - Network connectivity monitoring

### Firebase Services
- **firebase_core** ^2.32.0 - Firebase core SDK
- **firebase_remote_config** ^4.3.8 - Remote configuration
- **firebase_messaging** ^14.7.10 - Push notifications

### Maps & Location
- **google_maps_flutter** ^2.5.3 - Google Maps widget
- **google_maps_flutter_android** ^2.6.2 - Android-specific implementation
- **location** ^5.0.3 - Location services
- **geolocator** ^10.1.0 - Geolocation functionality
- **geocoding** ^2.1.1 - Address geocoding/reverse geocoding
- **map_launcher** ^3.1.0 - Launch external navigation apps
- **permission_handler** ^12.0.0+1 - Runtime permissions

### Audio Processing
- **record** ^6.0.0 - Audio recording
- **just_audio** ^0.9.35 - Audio playback
- **just_audio_cache** ^0.1.2 - Audio caching
- **flutter_sound** ^9.2.13 - Sound utilities
- **audio_session** ^0.1.16 - Audio session management

### UI Components & Design
- **flutter_screenutil** ^5.9.0 - Responsive UI scaling
- **flutter_svg** ^2.0.9 - SVG rendering
- **shimmer** ^3.0.0 - Shimmer loading effects
- **bot_toast** ^4.1.3 - Toast notifications
- **pinput** ^5.0.1 - PIN/OTP input widget
- **country_picker** ^2.0.27 - Country selection
- **intl_phone_field** ^3.2.0 - International phone input

### Utilities
- **intl** ^0.19.0 - Internationalization and formatting
- **logger** ^2.0.2+1 - Logging utility
- **image_picker** ^1.0.7 - Image selection from gallery/camera
- **url_launcher** ^6.3.1 - Launch URLs and apps
- **flutter_dotenv** ^5.1.0 - Environment variable management

### Development & Testing
- **flutter_test** - Flutter testing framework
- **bloc_test** ^9.1.5 - BLoC testing utilities
- **mockito** ^5.4.4 - Mocking framework
- **build_runner** ^2.4.7 - Code generation
- **flutter_lints** ^2.0.0 - Flutter linting rules
- **flutter_launcher_icons** ^0.14.3 - App icon generation

## 🚀 Getting Started

### Prerequisites

#### Required Software
- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0
- **Xcode**: Latest version (for iOS development on macOS)
- **Android Studio**: Latest version with Android SDK
- **CocoaPods**: Latest version (for iOS dependencies)

#### Third-Party Services
- **Google Maps API Key**: For map functionality
- **Firebase Project**: With the following services enabled:
  - Firebase Cloud Messaging (FCM)
  - Firebase Remote Config
  - Firebase Core
- **Backend API**: Access to the Ballot Access Pro backend API

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd "Ballot Access Pro"
   ```

2. **Create `.env` file** in the root directory with required environment variables:
   ```env
   # API Configuration
   BASE_URL_PROD=your_production_api_url
   SOCKET_URL_PROD=your_websocket_url
   WEB_URL_PROD=your_web_dashboard_url
   
   # Google Maps
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   
   # Analytics (Optional)
   SENTRY_DSN=your_sentry_dsn
   MIXPANEL_TOKEN_PROD=your_mixpanel_token
   ```

3. **Firebase Configuration**
   - Place `google-services.json` in `android/app/` directory
   - Place `GoogleService-Info.plist` in `ios/Runner/` directory

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **iOS-specific setup** (macOS only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Running the App

#### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with debug logging
flutter run --verbose
```

#### Available Run Configurations
- **Debug Mode**: Includes debug controls and logging
- **Profile Mode**: Performance profiling enabled
- **Release Mode**: Optimized production build

### Debugging

```bash
# Check for Flutter issues
flutter doctor

# View connected devices
flutter devices

# Clear build cache
flutter clean
```

## 📦 Building for Production

### Android Release Build

```bash
# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build APK (for direct distribution)
flutter build apk --release --split-per-abi
```

The output will be located at:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### iOS Release Build

```bash
# Build iOS app
flutter build ios --release

# For TestFlight/App Store
flutter build ipa --release
```

**Note**: See `testflight_deployment_guide.md` and `quick_testflight_deployment.md` in the root directory for detailed iOS deployment instructions.

### Build Configurations

- **Release**: Production-ready optimized build
- **Profile**: Performance profiling with some debug capabilities
- **Debug**: Full debugging support

## 🧪 Testing

The project includes comprehensive testing:

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/map_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Testing Stack
- **Unit Tests**: Core business logic testing
- **BLoC Tests**: State management testing with `bloc_test`
- **Widget Tests**: UI component testing
- **Mocking**: Using `mockito` for dependency mocking

## 📚 Project Structure

The project follows a **feature-first clean architecture** pattern with BLoC for state management:

```
ballot_access_pro/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── assets/                     # Static assets
│   ├── fonts/                 # Custom fonts (Marcellus)
│   ├── images/                # Image assets and logos
│   ├── svgs/                  # SVG icons
│   └── map_style.json         # Google Maps custom styling
├── lib/
│   ├── core/                  # Core application functionality
│   │   ├── api/              # API client configuration
│   │   ├── config/           # App configuration
│   │   ├── constants/        # App-wide constants
│   │   ├── services/         # Core services
│   │   ├── theme/            # App theming
│   │   ├── flavor_config.dart # Environment configuration
│   │   ├── locator.dart      # Dependency injection setup
│   │   └── theme.dart        # Theme configuration
│   ├── blocs/                 # Business Logic Components
│   │   └── auth/             # Authentication BLoCs
│   ├── features/              # Feature modules
│   │   └── auth/             # Authentication feature
│   ├── models/                # Data models
│   │   ├── api_response_model.dart
│   │   ├── audio_recording_model.dart
│   │   ├── house_visit_model.dart
│   │   ├── lead_model.dart
│   │   ├── petitioner_model.dart
│   │   ├── territory.dart
│   │   ├── territory_houses.dart
│   │   ├── user_location.dart
│   │   ├── user_model.dart
│   │   └── work_session_model.dart
│   ├── repositories/          # Data repositories (data abstraction layer)
│   │   └── house_repository.dart
│   ├── services/              # Business services
│   │   ├── api/              # API service implementations
│   │   ├── audio_service.dart         # Audio recording/playback
│   │   ├── auth_service.dart          # Authentication
│   │   ├── database_service.dart      # SQLite operations
│   │   ├── fcm_service.dart           # Push notifications
│   │   ├── local_storage_service.dart # Local storage
│   │   ├── map_service.dart           # Map operations
│   │   ├── petitioner_service.dart    # Petitioner operations
│   │   ├── socket_service.dart        # WebSocket communication
│   │   ├── sync_service.dart          # Data synchronization
│   │   ├── territory_service.dart     # Territory management
│   │   └── work_service.dart          # Work session tracking
│   ├── shared/                # Shared utilities and widgets
│   │   ├── constants/        # Shared constants
│   │   ├── navigation/       # Navigation setup and routes
│   │   ├── styles/           # Shared styles
│   │   ├── utils/            # Utility functions
│   │   └── widgets/          # Reusable widgets
│   ├── ui/                    # User Interface
│   │   ├── views/            # Screen views
│   │   └── widgets/          # UI widgets
│   └── main.dart              # Application entry point
├── test/                      # Test files
│   └── map_test.dart
├── .env                       # Environment variables (not in version control)
├── pubspec.yaml              # Project dependencies
└── README.md                 # This file
```

### Architecture Layers

1. **Presentation Layer** (`ui/`, `blocs/`)
   - UI screens and widgets
   - BLoC state management
   - User interaction handling

2. **Domain Layer** (`models/`, `repositories/`)
   - Business entities and models
   - Repository interfaces
   - Business logic abstractions

3. **Data Layer** (`services/`)
   - API communication
   - Local storage
   - External service integrations

4. **Core Layer** (`core/`)
   - Dependency injection
   - App configuration
   - Shared utilities

## 👥 Team & Workflow

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Follow existing code patterns
   - Add tests for new features

3. **Test your changes**
   ```bash
   flutter test
   flutter run  # Manual testing
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add descriptive commit message"
   ```

5. **Push and create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Convention

Follow conventional commits format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Test additions or changes
- `chore:` Build process or auxiliary tool changes

## 🛡️ Deployment

### TestFlight (iOS)

See dedicated deployment guides in the project root:
- `testflight_deployment_guide.md` - Complete step-by-step guide
- `quick_testflight_deployment.md` - Quick reference
- `testflight_prerequisites.md` - Required setup

### Google Play Store (Android)

1. Build release app bundle
2. Sign the bundle with your release keystore
3. Upload to Google Play Console
4. Complete store listing
5. Submit for review

## 📝 Additional Documentation

- **Fix Implementation Summary**: See `fix_implementation_summary.md`
- **TestFlight Deployment**: See deployment guides in root directory
- **Architecture Diagrams**: (To be added)
- **API Documentation**: (Contact backend team)

## 💬 Support & Contact

For questions, issues, or contributions:
- Create an issue in the repository
- Contact the development team
- Review existing documentation

## 📜 License

This project is **proprietary and confidential**. Unauthorized copying, distribution, or use is strictly prohibited.

© 2025 Ballot Access Pro. All rights reserved.

## Recent Fixes

### Map View Debug Mode Issues Fixed
- Improved `_initializeDebugMode()` method to ensure controls are visible in debug mode
- Added multiple refresh attempts to ensure UI elements are properly rendered
- Ensured territory and house markers are properly initialized
- Fixed marker initialization in the `build` method for debug mode

### Recording Player Issues Fixed
- Fixed play/pause icon toggle by updating UI state before async operations
- Improved slider value handling using `DebugUtils.safeSliderValue` and `safeSliderMaxValue` to prevent "Invalid argument(s): 0.0" error
- Enhanced caching detection to prevent showing the downloading indicator for already cached recordings
- Fixed file path handling for cached recordings

### Address Field Made Editable in Add Pin
- Made the address field editable in `AddHouseBottomSheet`
- Added a `setState` call to ensure UI updates when address is edited
- Updated `_handleMapLongPress` in `MapView` to properly use the edited address
- Added fallback to original address if edited address is empty
