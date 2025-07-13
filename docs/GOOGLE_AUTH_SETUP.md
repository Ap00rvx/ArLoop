# Google Authentication Setup Guide

This guide will help you set up Google authentication for the ArLoop Flutter app.

## Prerequisites

1. Google Cloud Console account
2. Flutter development environment
3. Android/iOS development setup

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API (if not already enabled)

## Step 2: Configure OAuth 2.0 Credentials

### For Android:

1. In Google Cloud Console, go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth 2.0 Client ID**
3. Select **Android** as application type
4. Set the package name: `com.arloop.arloop` (or your package name)
5. Get your SHA-1 certificate fingerprint:
   ```bash
   # For debug build
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # For release build (when you have a release keystore)
   keytool -list -v -keystore path/to/your/release-keystore.jks -alias your-alias
   ```
6. Copy the SHA-1 fingerprint and paste it in the Google Cloud Console
7. Save and copy the generated **Client ID**

### For iOS:

1. Create another OAuth 2.0 Client ID
2. Select **iOS** as application type
3. Set the bundle identifier: `com.arloop.arloop` (or your bundle ID)
4. Save and copy the generated **Client ID**

## Step 3: Configure Your App

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` file and replace the placeholder values:
   ```env
   CLIENT_ID=your_actual_android_client_id_here.apps.googleusercontent.com
   IOS_CLIENT_ID=your_actual_ios_client_id_here.apps.googleusercontent.com
   ```

3. **Important**: Add `.env` to your `.gitignore` file to keep your credentials secure:
   ```gitignore
   # Environment variables
   .env
   ```

## Step 4: Android Configuration

1. Download the `google-services.json` file from Firebase Console (if using Firebase) or create one manually
2. Place it in `android/app/` directory
3. Update `android/app/build.gradle` to include Google services plugin (if using Firebase)

## Step 5: iOS Configuration

1. Download the `GoogleService-Info.plist` file
2. Add it to your iOS project in Xcode under `ios/Runner/`
3. Update `ios/Runner/Info.plist` with URL schemes:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

## Step 6: Test the Integration

1. Run your app:
   ```bash
   flutter run
   ```

2. Navigate to the login page
3. Tap "Continue with Google"
4. Complete the Google sign-in flow
5. Verify that the user information is properly received

## Troubleshooting

### Common Issues:

1. **"Sign in failed" error**:
   - Check that your Client ID is correct in `.env`
   - Verify SHA-1 fingerprint is correctly configured
   - Ensure package name matches in Google Cloud Console

2. **"PlatformException" errors**:
   - Make sure google-services.json is in the correct location
   - Verify that Google services plugin is properly configured

3. **iOS build issues**:
   - Check that GoogleService-Info.plist is added to the project
   - Verify URL schemes are correctly configured in Info.plist

### Debug Steps:

1. Check the debug logs for detailed error messages
2. Verify network connectivity
3. Test with a different Google account
4. Clear app data and try again

## Security Notes

- Never commit your `.env` file to version control
- Keep your Client IDs and secrets secure
- Use different credentials for development and production
- Regularly rotate your credentials

## Production Deployment

When deploying to production:

1. Create production OAuth credentials in Google Cloud Console
2. Update your `.env` file with production values
3. Use proper code signing certificates
4. Test the authentication flow thoroughly

For more information, refer to the [Google Sign-In documentation](https://developers.google.com/identity/sign-in/android).
