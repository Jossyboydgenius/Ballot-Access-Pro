# TestFlight Deployment Guide for Ballot Access Pro

This guide will walk you through deploying your Flutter app to TestFlight for beta testing within 24 hours.

## Prerequisites

1. **Apple Developer Account**: You need an active Apple Developer account ($99/year).
2. **App Store Connect Access**: Make sure you have the right permissions (Admin or App Manager).
3. **Xcode**: Latest version installed on your Mac.
4. **Flutter**: Make sure your Flutter installation is up to date.
5. **App Icon**: Prepare app icons in various sizes (1024x1024 for App Store).
6. **App Screenshots**: For App Store submission (can be added later).

## Step 1: Register App Identifier

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list).
2. Click the "+" button to register a new identifier.
3. Select "App IDs" and click "Continue".
4. Select "App" and click "Continue".
5. Enter a description (e.g., "Ballot Access Pro").
6. Enter your Bundle ID (e.g., "com.yourcompany.ballotaccesspro").
7. Select any capabilities your app needs (e.g., Push Notifications).
8. Click "Continue" and then "Register".

## Step 2: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/).
2. Click "My Apps".
3. Click the "+" button and select "New App".
4. Fill in the required information:
   - Platforms: iOS
   - Name: "Ballot Access Pro"
   - Primary language: English (or your preferred language)
   - Bundle ID: Select the one you created earlier
   - SKU: A unique identifier (e.g., "ballotaccesspro2025")
   - User Access: Full Access
5. Click "Create".

## Step 3: Prepare iOS App for Release

1. Open your Flutter project in VS Code or your preferred editor.
2. Update the version in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1  # Format is version_name+version_code
   ```

3. Open the iOS project in Xcode:
   ```bash
   cd /Users/dreytech/Projects/Ballot\ Access\ Pro
   open ios/Runner.xcworkspace
   ```

4. In Xcode, select the "Runner" project in the left sidebar.
5. Select the "Runner" target.
6. Go to the "General" tab.
7. Verify the Bundle Identifier matches what you registered.
8. Make sure the Version and Build numbers match your pubspec.yaml.
9. Set up your Team for signing (your Apple Developer account).

## Step 4: Configure App Icons and Info.plist

1. In Xcode, open `Assets.xcassets` and update the AppIcon with your app icons.
2. Check your `Info.plist` file for any required permissions or settings.

## Step 5: Build Archive for TestFlight

1. In Xcode, select "Any iOS Device" from the device dropdown.
2. Go to Product > Archive.
3. Wait for the build to complete (this may take several minutes).
4. When the Archive is complete, the Organizer window will open.

## Step 6: Upload to TestFlight

1. In the Organizer window, select your archive.
2. Click "Distribute App".
3. Select "App Store Connect" and click "Next".
4. Select "Upload" and click "Next".
5. Select options for distribution:
   - Include bitcode: No
   - Strip Swift symbols: Yes
   - Upload your app's symbols: Yes
6. Click "Next".
7. Review the distribution options and click "Next".
8. Sign in with your Apple ID if prompted.
9. Click "Upload".

## Step 7: Configure TestFlight

1. Go back to [App Store Connect](https://appstoreconnect.apple.com/).
2. Select your app and go to the "TestFlight" tab.
3. Wait for the build to finish processing (can take 30 minutes to a few hours).
4. Once processed, you may need to provide export compliance information.
5. After compliance is approved, your build will be ready for testing.

## Step 8: Add Testers

1. In the TestFlight tab, go to "Testers & Groups".
2. You can add internal testers (people in your organization) or external testers.
3. For internal testing:
   - Add team members with their Apple IDs.
4. For external testing:
   - Create a group (e.g., "LA Project Team").
   - Add email addresses of your testers.
   - Click "Add" to invite them.

## Step 9: Distribute to Testers

1. Go back to the "Builds" section in TestFlight.
2. Select your build.
3. Click "Groups" and select the groups you want to distribute to.
4. Add release notes explaining what to test.
5. Click "Save" and then "Start Testing".

## Troubleshooting Common Issues

### Build Fails in Xcode
- Check signing configuration
- Verify all required certificates are installed
- Make sure your provisioning profile is valid

### Processing Takes Too Long
- Be patient, it can sometimes take several hours
- Ensure your internet connection is stable

### Testers Can't Install
- Verify they've accepted the TestFlight invitation
- Check if the build has been approved for testing
- Make sure they've installed the TestFlight app

## Quick Commands for Flutter iOS Build

If you prefer using command line:

```bash
# Update dependencies
flutter pub get

# Clean build
flutter clean

# Build iOS release
cd ios
pod install
cd ..
flutter build ios --release

# Then open Xcode to archive and upload
open ios/Runner.xcworkspace
```

## Next Steps After TestFlight

1. Collect feedback from your testers
2. Fix any issues reported
3. Upload new builds as needed
4. When ready, submit for App Store Review

Good luck with your LA project deployment! 