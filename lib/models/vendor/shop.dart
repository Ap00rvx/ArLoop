class Shop {
  final String? id;
  final String owner;
  final String operationalStatus;
  final String? statusMessage;
  final ShopServices services;
  final List<String> tags;
  final List<Announcement> announcements;
  final List<Holiday> holidays;
  final List<Certification> certifications;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    this.id,
    required this.owner,
    this.operationalStatus = 'closed',
    this.statusMessage,
    required this.services,
    this.tags = const [],
    this.announcements = const [],
    this.holidays = const [],
    this.certifications = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['_id'],
      owner: json['owner'],
      operationalStatus: json['operationalStatus'] ?? 'closed',
      statusMessage: json['statusMessage'],
      services: ShopServices.fromJson(json['services'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
      announcements: (json['announcements'] as List? ?? [])
          .map((item) => Announcement.fromJson(item))
          .toList(),
      holidays: (json['holidays'] as List? ?? [])
          .map((item) => Holiday.fromJson(item))
          .toList(),
      certifications: (json['certifications'] as List? ?? [])
          .map((item) => Certification.fromJson(item))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner,
      'operationalStatus': operationalStatus,
      'statusMessage': statusMessage,
      'services': services.toJson(),
      'tags': tags,
      'announcements': announcements.map((item) => item.toJson()).toList(),
      'holidays': holidays.map((item) => item.toJson()).toList(),
      'certifications': certifications.map((item) => item.toJson()).toList(),
    };
  }
}

class ShopServices {
  final HomeDelivery homeDelivery;

  ShopServices({required this.homeDelivery});

  factory ShopServices.fromJson(Map<String, dynamic> json) {
    return ShopServices(
      homeDelivery: HomeDelivery.fromJson(json['homeDelivery'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'homeDelivery': homeDelivery.toJson()};
  }
}

class HomeDelivery {
  final bool available;
  final double? radius;
  final double? minOrderValue;
  final double? deliveryFee;

  HomeDelivery({
    this.available = false,
    this.radius,
    this.minOrderValue,
    this.deliveryFee,
  });

  factory HomeDelivery.fromJson(Map<String, dynamic> json) {
    return HomeDelivery(
      available: json['available'] ?? false,
      radius: json['radius']?.toDouble(),
      minOrderValue: json['minOrderValue']?.toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'radius': radius,
      'minOrderValue': minOrderValue,
      'deliveryFee': deliveryFee,
    };
  }
}

// ===== Additional Shop Models =====

class Announcement {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endDate;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.endDate,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }
}

class Holiday {
  final String id;
  final DateTime date;
  final String reason;
  final bool isRecurring;
  final DateTime createdAt;

  Holiday({
    required this.id,
    required this.date,
    required this.reason,
    required this.isRecurring,
    required this.createdAt,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
      reason: json['reason'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'reason': reason,
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Certification {
  final String id;
  final String name;
  final String issuedBy;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String certificateNumber;
  final String? documentUrl;
  final bool isVerified;
  final DateTime createdAt;

  Certification({
    required this.id,
    required this.name,
    required this.issuedBy,
    required this.issuedDate,
    this.expiryDate,
    required this.certificateNumber,
    this.documentUrl,
    required this.isVerified,
    required this.createdAt,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      issuedBy: json['issuedBy'] ?? '',
      issuedDate: DateTime.parse(json['issuedDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      certificateNumber: json['certificateNumber'] ?? '',
      documentUrl: json['documentUrl'],
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'issuedBy': issuedBy,
      'issuedDate': issuedDate.toIso8601String(),
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
      'certificateNumber': certificateNumber,
      if (documentUrl != null) 'documentUrl': documentUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
