// File: lib/models/auth_response.dart
import 'package:arloop/models/user.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final User user;
  
  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class UserResponse {
  final bool success;
  final String message;
  final User user;
  
  UserResponse({
    required this.success,
    required this.message,
    required this.user,
  });
  
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      success: json['success'],
      message: json['message'],
      user: User.fromJson(json['user']),
    );
  }
}

class BaseResponse {
  final bool success;
  final String message;
  
  BaseResponse({
    required this.success,
    required this.message,
  });
  
  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}

class UsersResponse {
  final bool success;
  final String message;
  final UsersData data;
  
  UsersResponse({
    required this.success,
    required this.message,
    required this.data,
  });
  
  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      success: json['success'],
      message: json['message'],
      data: UsersData.fromJson(json['data']),
    );
  }
}

class UsersData {
  final List<User> users;
  final Pagination pagination;
  
  UsersData({
    required this.users,
    required this.pagination,
  });
  
  factory UsersData.fromJson(Map<String, dynamic> json) {
    return UsersData(
      users: (json['users'] as List).map((e) => User.fromJson(e)).toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final bool hasNextPage;
  final bool hasPrevPage;
  
  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
  
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalUsers: json['totalUsers'],
      hasNextPage: json['hasNextPage'],
      hasPrevPage: json['hasPrevPage'],
    );
  }
}