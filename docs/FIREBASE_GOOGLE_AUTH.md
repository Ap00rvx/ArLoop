# Firebase Google Authentication Setup

This guide covers the complete setup for Google Authentication using Firebase in your ArLoop Flutter app.

## Backend Integration

Your backend server at `https://arloop-server.onrender.com/` is already configured with the following endpoints:

### Google Auth Endpoint
```
POST /api/users/google-auth
```

**Request Body:**
```json
{
  "googleId": "firebase_user_uid",
  "name": "User Name",
  "email": "user@example.com",
  "profilePicture": "https://profile-url.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Google login successful",
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "name": "User Name",
    "email": "user@example.com",
    "phone": null,
    "profilePicture": "https://profile-url.jpg",
    "authProvider": "google",
    "isEmailVerified": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "isNewUser": true
}
```

### Complete Profile Endpoint (for new users)
```
PUT /api/users/complete-google-profile
Authorization: Bearer {jwt_token}
```

**Request Body:**
```json
{
  "phone": "1234567890"
}
```

## Flutter Implementation Features

### 1. Firebase Integration
- Uses Firebase Authentication for secure Google Sign-In
- Automatically handles Google OAuth flow
- Integrates with your existing backend

### 2. API Client Integration
- Uses your existing `ApiClient` class for backend communication
- Automatic token management
- Proper error handling

### 3. Secure Storage
- JWT tokens stored securely using `flutter_secure_storage`
- User data cached locally
- Automatic cleanup on sign out

### 4. UI Components
- Custom Google Sign-In button with loading states
- Profile completion dialog for new users
- Custom Google logo fallback

## Configuration

### Environment Variables (.env)
```env
CLIENT_ID="754170249123-ea9rog6kh9t1fhf5a6p75he5oi3eilqb.apps.googleusercontent.com"
API_BASE_URL="https://arloop-server.onrender.com/api"
```

### Firebase Configuration
Your `firebase_options.dart` is already configured with:
- Project ID: `arloop-728dc`
- Android App ID: `1:417472319648:android:9f8ec23007f72735cb79c5`
- iOS App ID: `1:417472319648:ios:64d24933cc92f50ccb79c5`

## Usage in Your App

### 1. Google Sign-In Button
```dart
GoogleSignInButton(
  onSuccess: () {
    // Navigate to home page or dashboard
    context.goNamed(RouteNames.home);
  },
  onError: (String errorMessage) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  },
)
```

### 2. Check Authentication Status
```dart
final authService = FirebaseGoogleAuthService();
final isAuthenticated = await authService.isAuthenticated();
```

### 3. Get User Data
```dart
final userData = await authService.getStoredUserData();
final userName = userData?['name'] ?? 'User';
```

### 4. Sign Out
```dart
await authService.signOut();
```

### 5. Get Authenticated API Client
```dart
final apiClient = await authService.getAuthenticatedApiClient();
// Now you can make authenticated API calls
final response = await apiClient.get('users/profile');
```

## Error Handling

### Common Error Codes:
- **DEVELOPER_ERROR (10)**: Configuration issue
  - Check CLIENT_ID in .env file
  - Verify SHA-1 fingerprint in Google Console
  - Ensure google-services.json is in android/app/

- **SIGN_IN_CANCELLED**: User cancelled sign-in
- **NETWORK_ERROR**: No internet connection
- **SIGN_IN_FAILED**: General sign-in failure

### Debugging:
1. Check debug console for detailed error messages
2. Verify your CLIENT_ID matches Google Cloud Console
3. Ensure backend is running and accessible
4. Test with different Google accounts

## Flow Diagram

```
User taps "Continue with Google"
    ↓
Google Sign-In Sheet appears
    ↓
User selects Google account
    ↓
Firebase Authentication
    ↓
Get Firebase User data
    ↓
Send to Backend (/api/users/google-auth)
    ↓
Backend checks if user exists
    ↓
┌─ New User: Create account
│   ↓
│   Return user data with isNewUser: true
│   ↓
│   Show profile completion dialog
│   ↓
│   User enters phone number
│   ↓
│   Call /api/users/complete-google-profile
│   ↓
│   Navigate to home
│
└─ Existing User: Login
    ↓
    Return user data with isNewUser: false
    ↓
    Navigate to home
```

## Security Notes

1. **Never commit .env file**: Add `.env` to your .gitignore
2. **Token Storage**: JWT tokens are stored securely using flutter_secure_storage
3. **API Communication**: All API calls use HTTPS
4. **Firebase Security**: Firebase handles OAuth securely
5. **Backend Validation**: Your backend validates all requests

## Testing

### Test Scenarios:
1. **New User**: First-time Google sign-in → Profile completion → Home
2. **Existing User**: Returning user → Direct to home
3. **Cancelled Sign-in**: User cancels → Proper error handling
4. **Network Issues**: No internet → Proper error message
5. **Invalid Token**: Expired token → Re-authentication

### Test with Debug Mode:
Enable debug logging to see detailed information:
```dart
if (kDebugMode) {
  print('Google Auth Debug Info');
}
```

## Production Checklist

- [ ] Replace CLIENT_ID with production values
- [ ] Update API_BASE_URL for production backend
- [ ] Test with release build
- [ ] Verify Google Cloud Console configuration
- [ ] Test sign-in flow end-to-end
- [ ] Test profile completion for new users
- [ ] Test sign-out functionality
- [ ] Verify secure token storage
