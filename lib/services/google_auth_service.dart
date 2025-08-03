import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _errorMessage = '';
  GoogleSignIn? _googleSignIn;

  // Scopes required by the application
  static const List<String> scopes = <String>['email', 'profile'];

  // Environment-based configuration using dotenv
  static String get _androidClientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get _iosClientId => dotenv.env['CLIENT_ID'] ?? '';
  static String get _webClientId => dotenv.env['CLIENT_ID'] ?? '';

  // Getters
  bool get isSignedIn => _currentUser != null;
  bool get isAuthorized => _isAuthorized;
  GoogleSignInAccount? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;

  /// Initialize Google Sign-In with environment-based client IDs
  Future<void> initialize() async {
    try {
      // Ensure dotenv is loaded
      if (!dotenv.isEveryDefined(['CLIENT_ID'])) {
        await dotenv.load(fileName: ".env");
      }

      // Determine client ID based on platform
      String? clientId;
      if (_googleSignIn != null) {
        print('Google Sign-In already initialized');
        return;
      }
      if (kIsWeb) {
        clientId = _webClientId.isEmpty ? null : _webClientId;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        clientId = _androidClientId.isEmpty ? null : _androidClientId;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        clientId = _iosClientId.isEmpty ? null : _iosClientId;
      }

      if (clientId == null || clientId.isEmpty) {
        throw Exception('Google Client ID not configured in .env file');
      }

      if (kDebugMode) {
        print('Using Google Client ID: ${clientId.substring(0, 10)}...');
      }

      _googleSignIn = GoogleSignIn(clientId: clientId, scopes: scopes);

      // Listen to authentication events
      _googleSignIn!.onCurrentUserChanged.listen(
        _handleUserChanged,
        onError: _handleError,
      );

      // Attempt silent sign-in
      await _googleSignIn!.signInSilently();

      if (kDebugMode) {
        print('Google Sign-In initialized successfully');
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize Google Sign-In: $e';
      if (kDebugMode) {
        print('Google Sign-In initialization error: $e');
      }
    }
  }

  /// Handle user authentication state changes
  Future<void> _handleUserChanged(GoogleSignInAccount? user) async {
    try {
      _currentUser = user;

      if (user != null) {
        // Check if user has authorized required scopes
        _isAuthorized = await _checkAuthorization();

        if (kDebugMode) {
          print('User signed in: ${user.email}, Authorized: $_isAuthorized');
        }
      } else {
        _isAuthorized = false;
        if (kDebugMode) {
          print('User signed out');
        }
      }

      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Error handling user change: $e';
      if (kDebugMode) {
        print('User change error: $e');
      }
    }
  }

  /// Handle authentication errors
  void _handleError(dynamic error) {
    _currentUser = null;
    _isAuthorized = false;
    _errorMessage = 'Authentication error: $error';

    if (kDebugMode) {
      print('Google Auth error: $error');
    }
  }

  /// Check if user has authorized required scopes
  Future<bool> _checkAuthorization() async {
    if (_currentUser == null) return false;

    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;
      return auth.accessToken != null;
    } catch (e) {
      if (kDebugMode) {
        print('Authorization check error: $e');
      }
      return false;
    }
  }

  /// Sign in with Google
  Future<GoogleUser?> signIn() async {
    try {
      if (_googleSignIn == null) {
        print('Google Sign-In not initialized, initializing now...');
        await initialize();
      }

      _errorMessage = '';
      print('Attempting to sign in with Google...');

      final GoogleSignInAccount? user = await _googleSignIn!.signIn();
      print('User signed in: $user');

      if (user != null) {
        _currentUser = user;
        _isAuthorized = await _checkAuthorization();

        return GoogleUser(
          email: user.email,
          name: user.displayName,
          googleId: user.id,
          imageUrl: user.photoUrl,
        );
      }
      return null;
    } catch (e) {
      _errorMessage = 'Sign-in failed: $e';
      if (kDebugMode) {
        print('Google Sign-In Error: $e');
      }
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Sign-out failed: $e';
      if (kDebugMode) {
        print('Google Sign-Out Error: $e');
      }
    }
  }

  /// Disconnect (revoke access)
  Future<void> disconnect() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.disconnect();
      }
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Disconnect failed: $e';
      if (kDebugMode) {
        print('Google Disconnect Error: $e');
      }
    }
  }

  /// Get current user
  GoogleUser? getCurrentUser() {
    if (_currentUser != null) {
      return GoogleUser(
        email: _currentUser!.email,
        name: _currentUser!.displayName,
        googleId: _currentUser!.id,
        imageUrl: _currentUser!.photoUrl,
      );
    }
    return null;
  }

  /// Silent sign-in
  Future<GoogleUser?> signInSilently() async {
    try {
      if (_googleSignIn == null) {
        await initialize();
      }

      final GoogleSignInAccount? user = await _googleSignIn!.signInSilently();

      if (user != null) {
        _currentUser = user;
        _isAuthorized = await _checkAuthorization();

        return GoogleUser(
          email: user.email,
          name: user.displayName,
          googleId: user.id,
          imageUrl: user.photoUrl,
        );
      }
      return null;
    } catch (e) {
      _errorMessage = 'Silent sign-in failed: $e';
      if (kDebugMode) {
        print('Silent Sign-In Error: $e');
      }
      return null;
    }
  }

  /// Get authentication token
  Future<String?> getAccessToken() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return null;
    }

    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;
      return auth.accessToken;
    } catch (e) {
      _errorMessage = 'Failed to get access token: $e';
      if (kDebugMode) {
        print('Access token error: $e');
      }
      return null;
    }
  }

  /// Get ID token
  Future<String?> getIdToken() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return null;
    }

    try {
      final GoogleSignInAuthentication auth =
          await _currentUser!.authentication;
      return auth.idToken;
    } catch (e) {
      _errorMessage = 'Failed to get ID token: $e';
      if (kDebugMode) {
        print('ID token error: $e');
      }
      return null;
    }
  }

  /// Get server auth code
  Future<String?> getServerAuthCode() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return null;
    }

    try {
      return _currentUser!.serverAuthCode;
    } catch (e) {
      _errorMessage = 'Failed to get server auth code: $e';
      if (kDebugMode) {
        print('Server auth code error: $e');
      }
      return null;
    }
  }

  /// Check if Google Sign-In is available
  bool isAvailable() {
    return _googleSignIn != null;
  }

  /// Get platform-specific client ID
  String? getCurrentClientId() {
    if (kIsWeb) {
      return _webClientId.isEmpty ? null : _webClientId;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidClientId.isEmpty ? null : _androidClientId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosClientId.isEmpty ? null : _iosClientId;
    }
    return null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
  }
}

/// Google User data model
class GoogleUser {
  final String email;
  final String? name;
  final String googleId;
  final String? imageUrl;

  GoogleUser({
    required this.email,
    this.name,
    required this.googleId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'googleId': googleId,
      'imageUrl': imageUrl,
    };
  }

  factory GoogleUser.fromJson(Map<String, dynamic> json) {
    return GoogleUser(
      email: json['email'],
      name: json['name'],
      googleId: json['googleId'],
      imageUrl: json['imageUrl'],
    );
  }

  @override
  String toString() {
    return 'GoogleUser{email: $email, name: $name, googleId: $googleId, imageUrl: $imageUrl}';
  }
}
