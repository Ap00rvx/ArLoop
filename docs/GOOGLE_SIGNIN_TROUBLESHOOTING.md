# Google Sign-In Troubleshooting Guide

## Error: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)

### Error Code 10 = DEVELOPER_ERROR

This error typically indicates a configuration issue. Here are the steps to resolve it:

## 1. Verify Google Cloud Console Configuration

### Step 1: Check OAuth 2.0 Client ID
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `arloop-728dc`
3. Navigate to **APIs & Services** > **Credentials**
4. Find your OAuth 2.0 Client ID for Android
5. Verify the package name is: `com.arloop.arloop`

### Step 2: Get Your SHA-1 Fingerprint
Run this command to get your debug SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For Windows:
```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Step 3: Update SHA-1 in Google Console
1. Copy the SHA-1 fingerprint from the keytool output
2. In Google Cloud Console, edit your Android OAuth client
3. Add the SHA-1 fingerprint
4. Save the changes

## 2. Verify Android Configuration

### Check build.gradle files:

**android/build.gradle.kts:**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}
```

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

### Check google-services.json:
1. Ensure `android/app/google-services.json` exists
2. Verify the package_name matches: `com.arloop.arloop`
3. Check client_id matches your .env CLIENT_ID

## 3. Verify Flutter Configuration

### pubspec.yaml dependencies:
```yaml
dependencies:
  firebase_core: ^3.15.1
  firebase_auth: ^5.6.2
  google_sign_in: ^6.3.0
```

### .env file:
```env
CLIENT_ID="754170249123-ea9rog6kh9t1fhf5a6p75he5oi3eilqb.apps.googleusercontent.com"
API_BASE_URL="https://arloop-server.onrender.com/api"
```

## 4. Clean and Rebuild

Run these commands:
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## 5. Enable Required APIs

In Google Cloud Console, ensure these APIs are enabled:
1. Google+ API
2. Google Sign-In API

## 6. Check Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `arloop-728dc`
3. Go to Authentication > Sign-in method
4. Ensure Google is enabled
5. Verify the Web SDK configuration

## 7. Debug Steps

### Enable Debug Logging:
In your Firebase service, debug information is already logged when `kDebugMode` is true.

### Common Issues:
1. **Package Name Mismatch**: Ensure `com.arloop.arloop` everywhere
2. **SHA-1 Not Added**: Must add debug SHA-1 to Google Console
3. **Wrong Client ID**: Ensure CLIENT_ID in .env matches Google Console
4. **Google Services Not Applied**: Check gradle files
5. **APIs Not Enabled**: Enable required APIs in Google Cloud Console

### Test with Different Accounts:
Try signing in with different Google accounts to isolate account-specific issues.

## 8. Alternative Configuration

If issues persist, try recreating the OAuth client:
1. Create a new OAuth 2.0 Client ID in Google Cloud Console
2. Download the new google-services.json
3. Update your .env with the new CLIENT_ID
4. Clean and rebuild the app

## 9. Production Setup

For production builds:
1. Generate release keystore
2. Get release SHA-1 fingerprint
3. Add release SHA-1 to Google Console
4. Create production OAuth client
5. Update .env with production CLIENT_ID

## 10. Verification Checklist

- [ ] Package name is `com.arloop.arloop` everywhere
- [ ] Debug SHA-1 is added to Google Cloud Console
- [ ] google-services.json is in android/app/
- [ ] Google services plugin is applied in build.gradle
- [ ] CLIENT_ID in .env matches Google Console
- [ ] Google+ API is enabled
- [ ] Firebase Authentication is enabled
- [ ] App has been cleaned and rebuilt

If all steps are completed and the error persists, check the Firebase Console logs for additional error details.
