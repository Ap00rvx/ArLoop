class StoreOwner {
  final String? id;
  final String ownerName;
  final String email;
  final String phone;
  final String? alternatePhone;
  final ShopDetails shopDetails;
  final BusinessInfo? businessInfo;
  final String accountStatus;
  final Subscription? subscription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreOwner({
    this.id,
    required this.ownerName,
    required this.email,
    required this.phone,
    this.alternatePhone,
    required this.shopDetails,
    this.businessInfo,
    this.accountStatus = 'pending',
    this.subscription,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreOwner.fromJson(Map<String, dynamic> json) {
    return StoreOwner(
      id: json['_id'],
      ownerName: json['ownerName'],
      email: json['email'],
      phone: json['phone'],
      alternatePhone: json['alternatePhone'],
      shopDetails: ShopDetails.fromJson(json['shopDetails']),
      businessInfo: json['businessInfo'] != null
          ? BusinessInfo.fromJson(json['businessInfo'])
          : null,
      accountStatus: json['accountStatus'] ?? 'pending',
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
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
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'alternatePhone': alternatePhone,
      'shopDetails': shopDetails.toJson(),
      'businessInfo': businessInfo?.toJson(),
      'accountStatus': accountStatus,
      'subscription': subscription?.toJson(),
    };
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }
}

class WorkingHours {
  final String openTime;
  final String closeTime;
  final List<String> workingDays;

  WorkingHours({
    required this.openTime,
    required this.closeTime,
    required this.workingDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime,
      'closeTime': closeTime,
      'workingDays': workingDays,
    };
  }

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      openTime: json['openTime'] ?? '',
      closeTime: json['closeTime'] ?? '',
      workingDays: List<String>.from(json['workingDays'] ?? []),
    );
  }
}

class ShopDetails {
  final String shopName;
  final String licenseNumber;
  final String? gstNumber;
  final ShopAddress shopAddress;
  final Location? location;
  final WorkingHours workingHours;

  ShopDetails({
    required this.shopName,
    required this.licenseNumber,
    this.gstNumber,
    required this.shopAddress,
    this.location,
    required this.workingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'licenseNumber': licenseNumber,
      if (gstNumber != null) 'gstNumber': gstNumber,
      'shopAddress': shopAddress.toJson(),
      if (location != null) 'location': location!.toJson(),
      'workingHours': workingHours.toJson(),
    };
  }

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      shopName: json['shopName'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      gstNumber: json['gstNumber'],
      shopAddress: ShopAddress.fromJson(json['shopAddress'] ?? {}),
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      workingHours: WorkingHours.fromJson(json['workingHours'] ?? {}),
    );
  }
}

class ShopAddress {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;

  ShopAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'] ?? 'India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }
}

class BusinessInfo {
  final bool deliveryAvailable;
  final String? description;
  final List<String>? specialties;

  BusinessInfo({
    this.deliveryAvailable = false,
    this.description,
    this.specialties,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      deliveryAvailable: json['deliveryAvailable'] ?? false,
      description: json['description'],
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryAvailable': deliveryAvailable,
      'description': description,
      'specialties': specialties,
    };
  }
}

class Subscription {
  final String plan;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Subscription({
    required this.plan,
    this.startDate,
    this.endDate,
    this.status = 'inactive',
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
    };
  }
}
