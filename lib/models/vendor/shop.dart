class Shop {
  final String? id;
  final String owner;
  final String operationalStatus;
  final String? statusMessage;
  final ShopServices services;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shop({
    this.id,
    required this.owner,
    this.operationalStatus = 'closed',
    this.statusMessage,
    required this.services,
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
