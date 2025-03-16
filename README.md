# Ballot Access Pro

A Flutter application for ballot access management. This mobile application helps streamline and manage ballot access processes.

## Features

- 📍 Location tracking and mapping integration with Google Maps
- 🔐 Secure storage and authentication
- 📱 Cross-platform support (iOS and Android)
- 🌍 Country selection and phone number validation
- 🔄 Real-time data synchronization
- 📡 Offline support
- 🎨 Modern and responsive UI
- 🔧 Firebase Remote Configuration

## Technology Stack

- **Framework**: Flutter (SDK >=3.0.0)
- **State Management**: Flutter Bloc
- **Dependencies**:
  - **State Management**: flutter_bloc, bloc, equatable
  - **Service Locator**: get_it
  - **Storage**: shared_preferences, flutter_secure_storage
  - **Networking**: dio, http
  - **Firebase**: firebase_remote_config
  - **Maps & Location**: google_maps_flutter, location, geolocator
  - **UI Components**: flutter_svg, flutter_screenutil, pinput, shimmer
  - **Utils**: intl, logger, image_picker

## Getting Started

### Prerequisites

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- iOS development setup (for iOS deployment)
- Android development setup (for Android deployment)
- Google Maps API Key
- Firebase project setup

### Environment Setup

1. Create a `.env` file in the root directory with the following variables:
   ```
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

### Installation

1. Clone the repository
   ```bash
   git clone [repository-url]
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Run the app
   ```bash
   flutter run
   ```

## Building for Production

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

The project includes unit tests and bloc tests. Run tests using:
```bash
flutter test
```

## Project Structure

The project follows a clean architecture pattern with BLoC for state management:

```
lib/
├── blocs/          # Business Logic Components
├── models/         # Data models
├── repositories/   # Data repositories
├── screens/        # UI screens
├── services/       # Services (API, storage, etc.)
├── utils/          # Utility functions
└── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is proprietary and confidential.
