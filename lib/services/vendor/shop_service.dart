import 'dart:io';
import '../../config/api.dart';
import '../../models/vendor/shop.dart';

class ShopService {
  static final ApiClient _apiClient = ApiClient();
  static const String _baseEndpoint = 'api/shop';

  /// Get shop details
  static Future<ApiResponse<Shop>> getShopDetails() async {
    try {
      final response = await _apiClient.get<Shop>(
        '$_baseEndpoint/details',
        fromJson: (json) => Shop.fromJson(json['shop']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Shop>(
        data: null,
        statusCode: 0,
        message: 'Failed to get shop details: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Update shop services
  static Future<ApiResponse<Shop>> updateShopServices({
    required List<String> services,
  }) async {
    try {
      final response = await _apiClient.put<Shop>(
        '$_baseEndpoint/services',
        body: {'services': services},
        fromJson: (json) => Shop.fromJson(json['shop']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Shop>(
        data: null,
        statusCode: 0,
        message: 'Failed to update shop services: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get shop statistics
  static Future<ApiResponse<ShopStatistics>> getShopStatistics() async {
    try {
      final response = await _apiClient.get<ShopStatistics>(
        '$_baseEndpoint/statistics',
        fromJson: (json) => ShopStatistics.fromJson(json['statistics']),
      );
      return response;
    } catch (e) {
      return ApiResponse<ShopStatistics>(
        data: null,
        statusCode: 0,
        message: 'Failed to get shop statistics: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Update shop tags
  static Future<ApiResponse<Shop>> updateShopTags({
    required List<String> tags,
  }) async {
    try {
      final response = await _apiClient.put<Shop>(
        '$_baseEndpoint/tags',
        body: {'tags': tags},
        fromJson: (json) => Shop.fromJson(json['shop']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Shop>(
        data: null,
        statusCode: 0,
        message: 'Failed to update shop tags: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  // ===== Announcement Methods =====

  /// Add announcement
  static Future<ApiResponse<Announcement>> addAnnouncement({
    required String title,
    required String message,
    String type = 'info',
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'title': title,
        'message': message,
        'type': type,
      };

      if (endDate != null) {
        body['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.post<Announcement>(
        '$_baseEndpoint/announcements',
        body: body,
        fromJson: (json) => Announcement.fromJson(json['announcement']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Announcement>(
        data: null,
        statusCode: 0,
        message: 'Failed to add announcement: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get active announcements
  static Future<ApiResponse<List<Announcement>>>
  getActiveAnnouncements() async {
    try {
      final response = await _apiClient.get<List<Announcement>>(
        '$_baseEndpoint/announcements/active',
        fromJson: (json) {
          final announcements = json['announcements'] as List;
          return announcements
              .map((item) => Announcement.fromJson(item))
              .toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse<List<Announcement>>(
        data: null,
        statusCode: 0,
        message: 'Failed to get active announcements: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Update announcement status
  static Future<ApiResponse<Announcement>> updateAnnouncementStatus({
    required String announcementId,
    required bool isActive,
  }) async {
    try {
      final response = await _apiClient.put<Announcement>(
        '$_baseEndpoint/announcements/$announcementId/status',
        body: {'isActive': isActive},
        fromJson: (json) => Announcement.fromJson(json['announcement']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Announcement>(
        data: null,
        statusCode: 0,
        message: 'Failed to update announcement status: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  // ===== Holiday Methods =====

  /// Add holiday
  static Future<ApiResponse<Holiday>> addHoliday({
    required DateTime date,
    required String reason,
    bool isRecurring = false,
  }) async {
    try {
      final response = await _apiClient.post<Holiday>(
        '$_baseEndpoint/holidays',
        body: {
          'date': date.toIso8601String(),
          'reason': reason,
          'isRecurring': isRecurring,
        },
        fromJson: (json) => Holiday.fromJson(json['holiday']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Holiday>(
        data: null,
        statusCode: 0,
        message: 'Failed to add holiday: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  // ===== Certification Methods =====

  /// Add certification
  static Future<ApiResponse<Certification>> addCertification({
    required String name,
    required String issuedBy,
    required DateTime issuedDate,
    required String certificateNumber,
    DateTime? expiryDate,
    String? documentUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name,
        'issuedBy': issuedBy,
        'issuedDate': issuedDate.toIso8601String(),
        'certificateNumber': certificateNumber,
      };

      if (expiryDate != null) {
        body['expiryDate'] = expiryDate.toIso8601String();
      }

      if (documentUrl != null) {
        body['documentUrl'] = documentUrl;
      }

      final response = await _apiClient.post<Certification>(
        '$_baseEndpoint/certifications',
        body: body,
        fromJson: (json) => Certification.fromJson(json['certification']),
      );
      return response;
    } catch (e) {
      return ApiResponse<Certification>(
        data: null,
        statusCode: 0,
        message: 'Failed to add certification: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Upload certification document
  static Future<ApiResponse<String>> uploadCertificationDocument({
    required File documentFile,
    required String certificateNumber,
  }) async {
    try {
      final response = await _apiClient.uploadFile<String>(
        '$_baseEndpoint/certifications/upload',
        documentFile,
        fieldName: 'document',
        additionalFields: {'certificateNumber': certificateNumber},
        fromJson: (json) => json['documentUrl'] as String,
      );
      return response;
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        statusCode: 0,
        message: 'Failed to upload certification document: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  // ===== Utility Methods =====

  /// Set authentication token
  static void setAuthToken(String token) {
    _apiClient.setAuthToken(token);
  }

  /// Clear authentication token
  static void clearAuthToken() {
    _apiClient.clearAuthToken();
  }
}

// ===== Model Classes =====

class ShopStatistics {
  final ShopMetrics metrics;
  final ShopInventory inventory;
  final ShopRatings ratings;
  final ProfileCompletion profileCompletion;
  final String operationalStatus;
  final ShopVerification verification;
  final int totalCertifications;
  final int activeAnnouncements;
  final int upcomingHolidays;

  ShopStatistics({
    required this.metrics,
    required this.inventory,
    required this.ratings,
    required this.profileCompletion,
    required this.operationalStatus,
    required this.verification,
    required this.totalCertifications,
    required this.activeAnnouncements,
    required this.upcomingHolidays,
  });

  factory ShopStatistics.fromJson(Map<String, dynamic> json) {
    return ShopStatistics(
      metrics: ShopMetrics.fromJson(json['metrics'] ?? {}),
      inventory: ShopInventory.fromJson(json['inventory'] ?? {}),
      ratings: ShopRatings.fromJson(json['ratings'] ?? {}),
      profileCompletion: ProfileCompletion.fromJson(
        json['profileCompletion'] ?? {},
      ),
      operationalStatus: json['operationalStatus'] ?? '',
      verification: ShopVerification.fromJson(json['verification'] ?? {}),
      totalCertifications: json['totalCertifications'] ?? 0,
      activeAnnouncements: json['activeAnnouncements'] ?? 0,
      upcomingHolidays: json['upcomingHolidays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metrics': metrics.toJson(),
      'inventory': inventory.toJson(),
      'ratings': ratings.toJson(),
      'profileCompletion': profileCompletion.toJson(),
      'operationalStatus': operationalStatus,
      'verification': verification.toJson(),
      'totalCertifications': totalCertifications,
      'activeAnnouncements': activeAnnouncements,
      'upcomingHolidays': upcomingHolidays,
    };
  }
}

class ShopMetrics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double revenue;
  final int totalCustomers;

  ShopMetrics({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.revenue,
    required this.totalCustomers,
  });

  factory ShopMetrics.fromJson(Map<String, dynamic> json) {
    return ShopMetrics(
      totalOrders: json['totalOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'revenue': revenue,
      'totalCustomers': totalCustomers,
    };
  }
}

class ShopInventory {
  final int totalMedicines;
  final int lowStockItems;
  final int outOfStockItems;

  ShopInventory({
    required this.totalMedicines,
    required this.lowStockItems,
    required this.outOfStockItems,
  });

  factory ShopInventory.fromJson(Map<String, dynamic> json) {
    return ShopInventory(
      totalMedicines: json['totalMedicines'] ?? 0,
      lowStockItems: json['lowStockItems'] ?? 0,
      outOfStockItems: json['outOfStockItems'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMedicines': totalMedicines,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
    };
  }
}

class ShopRatings {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingDistribution;

  ShopRatings({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ShopRatings.fromJson(Map<String, dynamic> json) {
    return ShopRatings(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: Map<String, int>.from(
        json['ratingDistribution'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
    };
  }
}

class ProfileCompletion {
  final double percentage;
  final List<String> missingFields;

  ProfileCompletion({required this.percentage, required this.missingFields});

  factory ProfileCompletion.fromJson(Map<String, dynamic> json) {
    return ProfileCompletion(
      percentage: (json['percentage'] ?? 0).toDouble(),
      missingFields: List<String>.from(json['missingFields'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'percentage': percentage, 'missingFields': missingFields};
  }
}

class ShopVerification {
  final bool isLicenseVerified;
  final bool isDocumentVerified;
  final bool isAddressVerified;
  final String verificationStatus;

  ShopVerification({
    required this.isLicenseVerified,
    required this.isDocumentVerified,
    required this.isAddressVerified,
    required this.verificationStatus,
  });

  factory ShopVerification.fromJson(Map<String, dynamic> json) {
    return ShopVerification(
      isLicenseVerified: json['isLicenseVerified'] ?? false,
      isDocumentVerified: json['isDocumentVerified'] ?? false,
      isAddressVerified: json['isAddressVerified'] ?? false,
      verificationStatus: json['verificationStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isLicenseVerified': isLicenseVerified,
      'isDocumentVerified': isDocumentVerified,
      'isAddressVerified': isAddressVerified,
      'verificationStatus': verificationStatus,
    };
  }
}
