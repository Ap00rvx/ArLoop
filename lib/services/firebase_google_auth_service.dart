import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/api.dart';

class FirebaseGoogleAuthService {
  static final FirebaseGoogleAuthService _instance =
      FirebaseGoogleAuthService._internal();
  factory FirebaseGoogleAuthService() => _instance;
  FirebaseGoogleAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();
  late GoogleSignIn _googleSignIn;

  String _errorMessage = '';
  bool _isInitialized = false;

  // Getters
  String get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  Future<void> initialize() async {
    try {
      final clientId = dotenv.env['CLIENT_ID'];
      if (clientId == null || clientId.isEmpty) {
        throw Exception('CLIENT_ID not found in environment variables');
      }

      _googleSignIn = GoogleSignIn(
        // clientId: clientId,
        scopes: ['email', 'profile'],
      );

      _isInitialized = true;
      _errorMessage = '';

      if (kDebugMode) {
        print('FirebaseGoogleAuthService initialized successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize Google Sign-In: $e';
      if (kDebugMode) {
        print(_errorMessage);
      }
    }
  }

  // Initialize API client with stored token
  Future<void> initializeApiClientWithToken() async {
    final String? backendToken = await _secureStorage.read(key: 'auth_token');
    if (backendToken != null) {
      _apiClient.setAuthToken(backendToken);
    }
  }

  Future<AuthResult?> signInWithGoogle() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      _errorMessage = '';

      // Sign out any previous sessions
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      // Start Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      print('Google user: $googleUser');

      if (googleUser == null) {
        _errorMessage = 'Sign in was cancelled by user';
        return null;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('Google auth: $googleAuth');

      // Prepare user data for backend
      final Map<String, dynamic> userData = {
        'googleId': googleUser.id,
        'name': googleUser.displayName ?? '',
        'email': googleUser.email ?? '',
        'profilePicture': googleUser.photoUrl,
      };

      // Send to backend for registration/login
      final BackendAuthResult? backendResult = await _authenticateWithBackend(
        userData,
      );

      if (backendResult == null) {
        // Backend authentication failed, sign out from Firebase
        await signOut();
        return null;
      }

      // Store tokens securely

      await _secureStorage.write(key: 'auth_token', value: backendResult.token);
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(backendResult.user),
      );

      return AuthResult(
        firebaseUser: googleUser,
        backendUser: backendResult.user,
        backendToken: backendResult.token,
        isNewUser: backendResult.isNewUser,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Firebase Auth Error: ${e.message}';
      if (kDebugMode) {
        print('FirebaseAuthException: ${e.code} - ${e.message}');
      }
      return null;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
      return null;
    }
  }

  Future<BackendAuthResult?> _authenticateWithBackend(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        'api/users/google-auth',
        body: userData,
      );

      if (kDebugMode) {
        print('Backend response status: ${response.statusCode}');
        print('Backend response: ${response.data}');
      }

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;

        if (responseData['success'] == true) {
          return BackendAuthResult(
            token: responseData['token'],
            user: responseData['user'],
            isNewUser: responseData['isNewUser'] ?? false,
          );
        } else {
          _errorMessage =
              responseData['message'] ?? 'Backend authentication failed';
          return null;
        }
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to communicate with backend: $e';
      if (kDebugMode) {
        print('Backend communication error: $e');
      }
      return null;
    }
  }

  Future<bool> completeProfile({required String phone}) async {
    try {
      final String? backendToken = await _secureStorage.read(key: 'auth_token');
      if (backendToken == null) {
        _errorMessage = 'No authentication token found';
        return false;
      }

      // Set the token for API client
      _apiClient.setAuthToken(backendToken);

      final response = await _apiClient.put<Map<String, dynamic>>(
        'api/users/complete-google-profile',
        body: {'phone': phone},
      );

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          // Update stored user data
          await _secureStorage.write(
            key: 'user_data',
            value: jsonEncode(responseData['user']),
          );
          return true;
        }
      }

      _errorMessage = response.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to complete profile: $e';
      return false;
    }
  }

  Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      final String? userData = await _secureStorage.read(key: 'user_data');
      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting stored user data: $e');
      }
      return null;
    }
  }

  Future<String?> getBackendToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear API client token
      _apiClient.clearAuthToken();

      // Clear stored tokens
      await _secureStorage.delete(key: 'firebase_id_token');
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_data');

      _errorMessage = '';

      if (kDebugMode) {
        print('User signed out successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
      if (kDebugMode) {
        print('Sign out error: $e');
      }
    }
  }

  // Get authenticated API client
  Future<ApiClient> getAuthenticatedApiClient() async {
    await initializeApiClientWithToken();
    return _apiClient;
  }

  // Check if user is authenticated (both Firebase and Backend)
  Future<bool> isAuthenticated() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    final String? backendToken = await _secureStorage.read(key: 'auth_token');

    return firebaseUser != null && backendToken != null;
  }

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}

// Data classes for type safety
class AuthResult {
  final GoogleSignInAccount firebaseUser;
  final Map<String, dynamic> backendUser;
  final String backendToken;
  final bool isNewUser;

  AuthResult({
    required this.firebaseUser,
    required this.backendUser,
    required this.backendToken,
    required this.isNewUser,
  });
}

class BackendAuthResult {
  final String token;
  final Map<String, dynamic> user;
  final bool isNewUser;

  BackendAuthResult({
    required this.token,
    required this.user,
    required this.isNewUser,
  });
}
