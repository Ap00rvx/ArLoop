import '../../config/api.dart';
import '../../models/vendor/store_owner.dart';
import '../../models/vendor/shop.dart';
import '../../models/vendor/auth_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreOwnerService {
  final ApiClient _apiClient = ApiClient();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Authentication endpoints
  Future<ApiResponse<AuthResponse>> register(
    StoreOwnerRegistrationRequest request,
  ) async {
    return await _apiClient.post<AuthResponse>(
      'api/store-owners/register',
      body: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  Future<ApiResponse<AuthResponse>> login(
    StoreOwnerLoginRequest request,
  ) async {
    return await _apiClient.post<AuthResponse>(
      'api/store-owners/login',
      body: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  // Profile management
  Future<ApiResponse<StoreOwnerProfileResponse>> getProfile() async {
    return await _apiClient.get<StoreOwnerProfileResponse>(
      'api/store-owners/profile',
      fromJson: (json) => StoreOwnerProfileResponse.fromJson(json),
    );
  }

  Future<ApiResponse<StoreOwner>> updateProfile(
    Map<String, dynamic> updateData,
  ) async {
    return await _apiClient.put<StoreOwner>(
      'api/store-owners/profile',
      body: updateData,
      fromJson: (json) => StoreOwner.fromJson(json['owner']),
    );
  }

  // Shop management
  Future<ApiResponse<Shop>> updateShopStatus({
    String? operationalStatus,
    String? statusMessage,
  }) async {
    final body = <String, dynamic>{};
    if (operationalStatus != null)
      body['operationalStatus'] = operationalStatus;
    if (statusMessage != null) body['statusMessage'] = statusMessage;

    return await _apiClient.put<Shop>(
      'api/store-owners/shop/status',
      body: body,
      fromJson: (json) => Shop.fromJson(json['shop']),
    );
  }

  // Public endpoints
  Future<ApiResponse<NearbyStoresResponse>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    return await _apiClient.get<NearbyStoresResponse>(
      'api/store-owners/nearby',
      queryParams: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      },
      fromJson: (json) => NearbyStoresResponse.fromJson(json),
    );
  }

  // Admin endpoints
  Future<ApiResponse<AllStoreOwnersResponse>> getAllStoreOwners({
    int page = 1,
    int limit = 10,
    String? status,
    String? city,
    bool? verified,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null) queryParams['status'] = status;
    if (city != null) queryParams['city'] = city;
    if (verified != null) queryParams['verified'] = verified.toString();

    return await _apiClient.get<AllStoreOwnersResponse>(
      'api/store-owners/all',
      queryParams: queryParams,
      fromJson: (json) => AllStoreOwnersResponse.fromJson(json),
    );
  }

  Future<ApiResponse<StoreOwner>> updateAccountStatus({
    required String ownerId,
    required String accountStatus,
    String? reason,
  }) async {
    final body = <String, dynamic>{'accountStatus': accountStatus};
    if (reason != null) body['reason'] = reason;

    return await _apiClient.put<StoreOwner>(
      'api/store-owners/$ownerId/status',
      body: body,
      fromJson: (json) => StoreOwner.fromJson(json['owner']),
    );
  }

  // Utility methods
  Future<void> setAuthToken(String token) async {
    _apiClient.setAuthToken(token);
    await _storage.write(key: 'store_owner_token', value: token);
  }

  Future<void> clearAuthToken() async {
    _apiClient.clearAuthToken();
    await _storage.delete(key: 'store_owner_token');
  }

  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'store_owner_token');
  }

  Future<bool> isTokenValid() async {
    final token = await getStoredToken();
    if (token == null) return false;

    try {
      // Try to make a simple authenticated request to validate token
      final response = await _apiClient.get('api/store-owners/profile');
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  Future<void> initialize() async {
    final token = await getStoredToken();
    if (token != null) {
      _apiClient.setAuthToken(token);
    }
  }
}

// Response models
class StoreOwnerProfileResponse {
  final bool success;
  final String message;
  final StoreOwner owner;
  final Shop? shop;

  StoreOwnerProfileResponse({
    required this.success,
    required this.message,
    required this.owner,
    this.shop,
  });

  factory StoreOwnerProfileResponse.fromJson(Map<String, dynamic> json) {
    return StoreOwnerProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      owner: StoreOwner.fromJson(json['owner']),
      shop: json['shop'] != null ? Shop.fromJson(json['shop']) : null,
    );
  }
}

class NearbyStoresResponse {
  final bool success;
  final String message;
  final List<StoreOwner> stores;
  final int count;

  NearbyStoresResponse({
    required this.success,
    required this.message,
    required this.stores,
    required this.count,
  });

  factory NearbyStoresResponse.fromJson(Map<String, dynamic> json) {
    return NearbyStoresResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      stores: (json['stores'] as List)
          .map((store) => StoreOwner.fromJson(store))
          .toList(),
      count: json['count'] ?? 0,
    );
  }
}

class AllStoreOwnersResponse {
  final bool success;
  final String message;
  final StoreOwnersData data;

  AllStoreOwnersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AllStoreOwnersResponse.fromJson(Map<String, dynamic> json) {
    return AllStoreOwnersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StoreOwnersData.fromJson(json['data']),
    );
  }
}

class StoreOwnersData {
  final List<StoreOwner> owners;
  final PaginationInfo pagination;

  StoreOwnersData({required this.owners, required this.pagination});

  factory StoreOwnersData.fromJson(Map<String, dynamic> json) {
    return StoreOwnersData(
      owners: (json['owners'] as List)
          .map((owner) => StoreOwner.fromJson(owner))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalOwners;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalOwners,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalOwners: json['totalOwners'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
