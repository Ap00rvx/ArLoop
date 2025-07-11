import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _errorMessage = '';

  // Scopes required by the application
  static const List<String> scopes = <String>['email', 'profile'];

  // Client ID - replace with your actual client ID
  String? clientId = dotenv.env["CLIENT_ID"]; // Add your client ID here
  static String? serverClientId =
      dotenv.env["CLIENT_ID"]; // Add your server client ID here

  bool get isSignedIn => _currentUser != null;
  bool get isAuthorized => _isAuthorized;
  GoogleSignInAccount? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;

  /// Initialize Google Sign-In
  Future<void> initialize() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize(clientId: clientId);

      // Listen to authentication events
      signIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError,
      );

      // Attempt lightweight authentication
      await signIn.attemptLightweightAuthentication();
    } catch (e) {
      _errorMessage = 'Failed to initialize Google Sign-In: $e';
      if (kDebugMode) {
        print('Google Sign-In initialization error: $e');
      }
    }
  }

  /// Handle authentication events
  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    print(clientId);
    print(serverClientId);
    try {
      final GoogleSignInAccount? user = switch (event) {
        GoogleSignInAuthenticationEventSignIn() => event.user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };

      // Check for existing authorization
      final GoogleSignInClientAuthorization? authorization = await user
          ?.authorizationClient
          .authorizationForScopes(scopes);

      _currentUser = user;
      _isAuthorized = authorization != null;
      _errorMessage = '';

      if (kDebugMode) {
        print(
          'Authentication event: User = ${user?.email}, Authorized = $_isAuthorized',
        );
      }
    } catch (e) {
      _errorMessage = 'Authentication event error: $e';
      if (kDebugMode) {
        print('Authentication event error: $e');
      }
    }
  }

  /// Handle authentication errors
  Future<void> _handleAuthenticationError(Object error) async {
    _currentUser = null;
    _isAuthorized = false;
    _errorMessage = error is GoogleSignInException
        ? _errorMessageFromSignInException(error)
        : 'Unknown error: $error';

    if (kDebugMode) {
      print('Authentication error: $_errorMessage');
    }
  }

  /// Sign in with Google
  Future<GoogleUser?> signIn() async {
    try {
      print(clientId);
      print(serverClientId);
      _errorMessage = '';

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.authenticate();
      } else {
        throw Exception('Google Sign-In not supported on this platform');
      }

      if (_currentUser != null) {
        return GoogleUser(
          email: _currentUser!.email,
          name: _currentUser!.displayName,
          googleId: _currentUser!.id,
          imageUrl: _currentUser!.photoUrl,
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
      await GoogleSignIn.instance.signOut();
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
      await GoogleSignIn.instance.disconnect();
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

  /// Request additional scopes
  Future<bool> requestScopes(List<String> additionalScopes) async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return false;
    }

    try {
      final GoogleSignInClientAuthorization authorization = await _currentUser!
          .authorizationClient
          .authorizeScopes([...scopes, ...additionalScopes]);

      _isAuthorized = true;
      _errorMessage = '';
      return true;
    } catch (e) {
      _errorMessage = e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Scope authorization failed: $e';
      if (kDebugMode) {
        print('Scope authorization error: $e');
      }
      return false;
    }
  }

  /// Get server auth code
  Future<String?> getServerAuthCode() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return null;
    }

    try {
      final GoogleSignInServerAuthorization? serverAuth = await _currentUser!
          .authorizationClient
          .authorizeServer(scopes);

      return serverAuth?.serverAuthCode;
    } catch (e) {
      _errorMessage = e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Server auth code request failed: $e';
      if (kDebugMode) {
        print('Server auth code error: $e');
      }
      return null;
    }
  }

  /// Get authorization headers for API calls
  Future<Map<String, String>?> getAuthHeaders() async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in';
      return null;
    }

    try {
      return await _currentUser!.authorizationClient.authorizationHeaders(
        scopes,
      );
    } catch (e) {
      _errorMessage = 'Failed to get authorization headers: $e';
      if (kDebugMode) {
        print('Authorization headers error: $e');
      }
      return null;
    }
  }

  /// Convert GoogleSignInException to user-friendly message
  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in was canceled',
      GoogleSignInExceptionCode.interrupted => 'Network error occurred',
      GoogleSignInExceptionCode.canceled => 'Sign in required',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
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
