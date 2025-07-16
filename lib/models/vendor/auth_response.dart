import 'store_owner.dart';
import 'shop.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final StoreOwner? owner;
  final Shop? shop;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.owner,
    this.shop,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      owner: json['owner'] != null ? StoreOwner.fromJson(json['owner']) : null,
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
    );
  }
}

class StoreOwnerRegistrationRequest {
  final String ownerName;
  final String email;
  final String password;
  final String phone;
  final String? alternatePhone;
  final ShopDetails shopDetails;
  final BusinessInfo? businessInfo;

  StoreOwnerRegistrationRequest({
    required this.ownerName,
    required this.email,
    required this.password,
    required this.phone,
    this.alternatePhone,
    required this.shopDetails,
    this.businessInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'email': email,
      'password': password,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'shopDetails': shopDetails.toJson(),
      'businessInfo': businessInfo?.toJson(),
    };
  }
}

class StoreOwnerLoginRequest {
  final String email;
  final String password;

  StoreOwnerLoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
