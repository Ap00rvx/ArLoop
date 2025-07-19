import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api.dart';
import '../models/user.dart';
import '../models/auth_response.dart';

class AuthenticationService {
  final ApiClient _client = ApiClient();

  // FlutterSecureStorage instance
  static const _storage = FlutterSecureStorage();

  // Secure storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Current user state
  User? _currentUser;
  String? _authToken;
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize authentication service
  Future<void> initialize() async {
    try {
      _authToken = await _storage.read(key: _tokenKey);
      final isLoggedInStr = await _storage.read(key: _isLoggedInKey);
      _isLoggedIn = isLoggedInStr == 'true';

      if (_authToken != null) {
        _client.setAuthToken(_authToken!);

        // Load user data
        final userJson = await _storage.read(key: _userKey);
        if (userJson != null) {
          try {
            _currentUser = User.fromJsonString(userJson);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing stored user data: $e');
            }
            await logout(); // Clear invalid data
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth service: $e');
      }
    }
  }

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _client.post<AuthResponse>(
        'api/users/register',
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        await _saveAuthData(response.data!);
        return AuthResult.success(
          user: response.data!.user,
          message: response.data!.message,
        );
      } else {
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        message: 'Registration failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<AuthResponse>(
        'api/users/login',
        body: {'email': email, 'password': password},
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      print(response.data);

      if (response.isSuccess && response.data != null) {
        await _saveAuthData(response.data!);
        return AuthResult.success(
          user: response.data!.user,
          message: response.data!.message,
        );
      } else {
        print("here");
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("her2e");
      return AuthResult.failure(
        message: 'Login failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Get user profile
  Future<AuthResult> getUserProfile() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return AuthResult.failure(
          message: 'User not logged in',
          statusCode: 401,
        );
      }

      final response = await _client.get<UserResponse>(
        headers: {'Authorization': 'Bearer $token'},
        'api/users/profile',
        fromJson: (json) => UserResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        _currentUser = response.data!.user;
        await _saveUserData();

        return AuthResult.success(
          user: response.data!.user,
          message: response.data!.message,
        );
      } else {
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print("here2");
      return AuthResult.failure(
        message: 'Failed to get profile: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({String? name, String? phone}) async {
    try {
      if (!_isLoggedIn) {
        return AuthResult.failure(
          message: 'User not logged in',
          statusCode: 401,
        );
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      final response = await _client.put<UserResponse>(
        'api/users/profile',
        body: body,
        fromJson: (json) => UserResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        _currentUser = response.data!.user;
        await _saveUserData();

        return AuthResult.success(
          user: response.data!.user,
          message: response.data!.message,
        );
      } else {
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to update profile: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (!_isLoggedIn) {
        return AuthResult.failure(
          message: 'User not logged in',
          statusCode: 401,
        );
      }

      final response = await _client.put<BaseResponse>(
        'api/users/change-password',
        body: {'currentPassword': currentPassword, 'newPassword': newPassword},
        fromJson: (json) => BaseResponse.fromJson(json),
      );

      if (response.isSuccess) {
        return AuthResult.success(
          message: response.data?.message ?? 'Password changed successfully',
        );
      } else {
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to change password: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Delete user account
  Future<AuthResult> deleteAccount() async {
    try {
      if (!_isLoggedIn) {
        return AuthResult.failure(
          message: 'User not logged in',
          statusCode: 401,
        );
      }

      final response = await _client.delete<BaseResponse>(
        'api/users/account',
        fromJson: (json) => BaseResponse.fromJson(json),
      );

      if (response.isSuccess) {
        await logout(); // Clear all data
        return AuthResult.success(
          message: response.data?.message ?? 'Account deleted successfully',
        );
      } else {
        return AuthResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return AuthResult.failure(
        message: 'Failed to delete account: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Get all users (Admin functionality)
  Future<UsersResult> getAllUsers({int page = 1, int limit = 10}) async {
    try {
      if (!_isLoggedIn) {
        return UsersResult.failure(
          message: 'User not logged in',
          statusCode: 401,
        );
      }

      final response = await _client.get<UsersResponse>(
        'api/users/all',
        queryParams: {'page': page, 'limit': limit},
        fromJson: (json) => UsersResponse.fromJson(json),
      );

      if (response.isSuccess && response.data != null) {
        return UsersResult.success(
          users: response.data!.data.users,
          pagination: response.data!.data.pagination,
          message: response.data!.message,
        );
      } else {
        return UsersResult.failure(
          message: response.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return UsersResult.failure(
        message: 'Failed to get users: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _currentUser = null;
      _authToken = null;
      _isLoggedIn = false;

      _client.clearAuthToken();

      // Clear all secure storage data
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _isLoggedInKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    try {
      _authToken = authResponse.token;
      _currentUser = authResponse.user;
      _isLoggedIn = true;

      _client.setAuthToken(_authToken!);

      // Save to secure storage
      await _storage.write(key: _tokenKey, value: _authToken!);
      await _storage.write(key: _isLoggedInKey, value: 'true');
      await _saveUserData();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving auth data: $e');
      }
    }
  }

  /// Save user data
  Future<void> _saveUserData() async {
    try {
      if (_currentUser != null) {
        await _storage.write(
          key: _userKey,
          value: _currentUser!.toJsonString(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  /// Check if token is valid
  Future<bool> isTokenValid() async {
    if (!_isLoggedIn || _authToken == null) {
      return false;
    }

    try {
      final result = await getUserProfile();
      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_isLoggedIn) {
      await getUserProfile();
    }
  }

  /// Clear all secure storage data (for debugging/testing)
  Future<void> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
      _currentUser = null;
      _authToken = null;
      _isLoggedIn = false;
      _client.clearAuthToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing secure data: $e');
      }
    }
  }

  /// Check if secure storage contains auth data
  Future<bool> hasStoredAuthData() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null;
    } catch (e) {
      return false;
    }
  }

  /// Get all stored keys (for debugging)
  Future<Map<String, String>> getAllStoredData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error reading all stored data: $e');
      }
      return {};
    }
  }
}

/// Authentication result wrapper
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String message;
  final int statusCode;

  AuthResult._({
    required this.isSuccess,
    this.user,
    required this.message,
    required this.statusCode,
  });

  factory AuthResult.success({User? user, required String message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
      statusCode: 200,
    );
  }

  factory AuthResult.failure({
    required String message,
    required int statusCode,
  }) {
    return AuthResult._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

/// Users result wrapper
class UsersResult {
  final bool isSuccess;
  final List<User>? users;
  final Pagination? pagination;
  final String message;
  final int statusCode;

  UsersResult._({
    required this.isSuccess,
    this.users,
    this.pagination,
    required this.message,
    required this.statusCode,
  });

  factory UsersResult.success({
    required List<User> users,
    required Pagination pagination,
    required String message,
  }) {
    return UsersResult._(
      isSuccess: true,
      users: users,
      pagination: pagination,
      message: message,
      statusCode: 200,
    );
  }

  factory UsersResult.failure({
    required String message,
    required int statusCode,
  }) {
    return UsersResult._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
