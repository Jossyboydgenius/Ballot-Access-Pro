# Quick TestFlight Deployment Guide (24-Hour Timeline)

## Immediate Steps (First 2 Hours)

1. **Update App Version**
   - Current version in pubspec.yaml is already `1.0.0+1` which is fine for first release

2. **Prepare App Icon**
   - Make sure you have a 1024x1024 app icon ready
   - Icons for other sizes should be generated automatically by Xcode

3. **Clean and Update Dependencies**
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

4. **Configure iOS Project**
   ```bash
   open ios/Runner.xcworkspace
   ```
   - In Xcode, select the "Runner" project
   - Go to the "Signing & Capabilities" tab
   - Select your Team (Apple Developer account)
   - Verify Bundle Identifier (e.g., "com.yourcompany.ballotaccesspro")
   - Make sure App Icons are properly set in Assets.xcassets

## Apple Developer Portal Setup (Next 2 Hours)

5. **Create App ID**
   - Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
   - Register a new App ID with your Bundle Identifier
   - Enable necessary capabilities (Push Notifications, etc.)

6. **Create App in App Store Connect**
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Click "My Apps" → "+" → "New App"
   - Fill in required information:
     - Name: "Ballot Access Pro"
     - Bundle ID: Select the one you created
     - SKU: A unique identifier (e.g., "ballotaccesspro2025")

## Build and Upload (Next 4 Hours)

7. **Build Archive**
   - In Xcode, select "Any iOS Device" from the device dropdown
   - Go to Product → Archive
   - Wait for the build to complete

8. **Upload to TestFlight**
   - In the Organizer window, select your archive
   - Click "Distribute App"
   - Select "App Store Connect" and click "Next"
   - Select "Upload" and click "Next"
   - Configure distribution options:
     - Include bitcode: No
     - Strip Swift symbols: Yes
     - Upload symbols: Yes
   - Click "Next" and then "Upload"

## TestFlight Configuration (Next 4 Hours)

9. **Wait for Processing**
   - Processing typically takes 30 minutes to a few hours
   - Check status in App Store Connect → TestFlight tab

10. **Provide Export Compliance Info**
    - Once processed, you may need to answer export compliance questions:
      - Does your app use encryption? Usually select "No" unless you've implemented custom encryption
    - Submit compliance information

11. **Add Test Information**
    - Add test information in the TestFlight tab:
      - What to test
      - Contact information
      - Review notes

## Add Testers and Distribute (Final Hours)

12. **Add Internal Testers**
    - In TestFlight tab, go to "Testers & Groups"
    - Add team members with their Apple IDs
    - These can test immediately without App Review

13. **Add External Testers (LA Project Team)**
    - Create a group named "LA Project Team"
    - Add email addresses of your testers
    - Click "Add" to invite them

14. **Distribute to Testers**
    - Go back to "Builds" section
    - Select your build
    - Click "Groups" and select the groups
    - Add release notes explaining what to test
    - Click "Save" and "Start Testing"

## Troubleshooting Quick Fixes

- **Build Fails**: Check signing configuration and certificates
- **Upload Fails**: Check internet connection and try again
- **Processing Stuck**: Be patient, it can take several hours
- **Testers Can't Install**: Make sure they've accepted the invitation and installed TestFlight app

## Follow-up (After 24 Hours)

- Check if all testers have received and installed the app
- Collect initial feedback
- Be ready to address critical issues with a new build

## Command Line Quick Reference

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

# Open Xcode to archive and upload
open ios/Runner.xcworkspace
``` 