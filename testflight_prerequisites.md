# TestFlight Prerequisites Fix Guide

Before proceeding with the TestFlight deployment, you need to fix the following issues detected by `flutter doctor`:

## 1. Fix Xcode Installation

```bash
# Install Xcode from the App Store if not already installed
# Once installed, run:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

## 2. Install CocoaPods

```bash
# Install CocoaPods using Homebrew
brew install cocoapods

# Verify installation
pod --version
```

## 3. Setup iOS Project

```bash
# Navigate to the iOS folder
cd ios

# Install pod dependencies
pod install

# Return to project root
cd ..
```

## 4. Verify Flutter Setup

After completing the above steps, run:

```bash
flutter doctor -v
```

Make sure all checkmarks are green before proceeding with the TestFlight deployment.

## 5. Verify iOS Simulator

```bash
# Open iOS simulator
open -a Simulator

# Run the app on the simulator to verify it works
flutter run
```

Once all prerequisites are fixed, you can proceed with the TestFlight deployment guide. 