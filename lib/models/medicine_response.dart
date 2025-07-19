// To parse this JSON data, do
//
//     final medicineResponse = medicineResponseFromJson(jsonString);

import 'dart:convert';

MedicineResponse medicineResponseFromJson(String str) =>
    MedicineResponse.fromJson(json.decode(str));

String medicineResponseToJson(MedicineResponse data) =>
    json.encode(data.toJson());

class MedicineResponse {
  bool? success;
  String message;
  Data data;

  MedicineResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MedicineResponse.fromJson(Map<String, dynamic> json) =>
      MedicineResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<Medicine> medicines;
  Pagination pagination;

  Data({required this.medicines, required this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    medicines: List<Medicine>.from(
      json["medicines"].map((x) => Medicine.fromJson(x)),
    ),
    pagination: Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "medicines": List<dynamic>.from(medicines.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Medicine {
  Pricing pricing;
  Stock stock;
  String id;
  String medicineName;
  String genericName;
  String manufacturer;
  String category;
  String therapeuticClass;
  StoreOwner storeOwner;
  String composition;
  String strength;
  String dosageForm;
  bool? prescriptionRequired;
  String scheduleType;
  String status;
  List<dynamic> sideEffects;
  List<dynamic> contraindications;
  List<dynamic> drugInteractions;
  String storageConditions;
  List<dynamic> keywords;
  int totalSold;
  int averageRating;
  bool? isVisible;
  bool? isFeatured;
  List<dynamic> batchDetails;
  List<dynamic> images;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Medicine({
    required this.pricing,
    required this.stock,
    required this.id,
    required this.medicineName,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.therapeuticClass,
    required this.storeOwner,
    required this.composition,
    required this.strength,
    required this.dosageForm,
    required this.prescriptionRequired,
    required this.scheduleType,
    required this.status,
    required this.sideEffects,
    required this.contraindications,
    required this.drugInteractions,
    required this.storageConditions,
    required this.keywords,
    required this.totalSold,
    required this.averageRating,
    required this.isVisible,
    required this.isFeatured,
    required this.batchDetails,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    print(json.entries.map((e) => '${e.key}: ${e.value.runtimeType}').join(', '));
    return Medicine(
      pricing: Pricing.fromJson(json["pricing"]),
      stock: Stock.fromJson(json["stock"]),
      id: json["_id"],
      medicineName: json["medicineName"],
      genericName: json["genericName"],
      manufacturer: json["manufacturer"],
      category: json["category"],
      therapeuticClass: json["therapeuticClass"],
      storeOwner: StoreOwner.fromJson(json["storeOwner"]),
      composition: json["composition"],
      strength: json["strength"],
      dosageForm: json["dosageForm"],
      prescriptionRequired: json["prescriptionRequired"],
      scheduleType: json["scheduleType"],
      status: json["status"],
      sideEffects: List<dynamic>.from(json["sideEffects"].map((x) => x)),
      contraindications: List<dynamic>.from(
        json["contraindications"].map((x) => x),
      ),
      drugInteractions: List<dynamic>.from(
        json["drugInteractions"].map((x) => x),
      ),
      storageConditions: json["storageConditions"],
      keywords: List<dynamic>.from(json["keywords"].map((x) => x)),
      totalSold: json["totalSold"],
      averageRating: json["averageRating"],
      isVisible: json["isVisible"],
      isFeatured: json["isFeatured"],
      batchDetails: List<dynamic>.from(json["batchDetails"].map((x) => x)),
      images: List<dynamic>.from(json["images"].map((x) => x)),
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "pricing": pricing.toJson(),
    "stock": stock.toJson(),
    "_id": id,
    "medicineName": medicineName,
    "genericName": genericName,
    "manufacturer": manufacturer,
    "category": category,
    "therapeuticClass": therapeuticClass,
    "storeOwner": storeOwner.toJson(),
    "composition": composition,
    "strength": strength,
    "dosageForm": dosageForm,
    "prescriptionRequired": prescriptionRequired,
    "scheduleType": scheduleType,
    "status": status,
    "sideEffects": List<dynamic>.from(sideEffects.map((x) => x)),
    "contraindications": List<dynamic>.from(contraindications.map((x) => x)),
    "drugInteractions": List<dynamic>.from(drugInteractions.map((x) => x)),
    "storageConditions": storageConditions,
    "keywords": List<dynamic>.from(keywords.map((x) => x)),
    "totalSold": totalSold,
    "averageRating": averageRating,
    "isVisible": isVisible,
    "isFeatured": isFeatured,
    "batchDetails": List<dynamic>.from(batchDetails.map((x) => x)),
    "images": List<dynamic>.from(images.map((x) => x)),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class Pricing {
  int mrp;
  int sellingPrice;
  int discountPercentage;

  Pricing({
    required this.mrp,
    required this.sellingPrice,
    required this.discountPercentage,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    mrp: json["mrp"],
    sellingPrice: json["sellingPrice"],
    discountPercentage: json["discountPercentage"],
  );

  Map<String, dynamic> toJson() => {
    "mrp": mrp,
    "sellingPrice": sellingPrice,
    "discountPercentage": discountPercentage,
  };
}

class Stock {
  int totalQuantity;
  int availableQuantity;
  int minimumStockLevel;
  String unit;
  int reservedQuantity;

  Stock({
    required this.totalQuantity,
    required this.availableQuantity,
    required this.minimumStockLevel,
    required this.unit,
    required this.reservedQuantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
    totalQuantity: json["totalQuantity"],
    availableQuantity: json["availableQuantity"],
    minimumStockLevel: json["minimumStockLevel"],
    unit: json["unit"],
    reservedQuantity: json["reservedQuantity"],
  );

  Map<String, dynamic> toJson() => {
    "totalQuantity": totalQuantity,
    "availableQuantity": availableQuantity,
    "minimumStockLevel": minimumStockLevel,
    "unit": unit,
    "reservedQuantity": reservedQuantity,
  };
}

class StoreOwner {
  ShopDetails shopDetails;
  String id;
  String ownerName;
  String accountStatus;

  StoreOwner({
    required this.shopDetails,
    required this.id,
    required this.ownerName,
    required this.accountStatus,
  });

  factory StoreOwner.fromJson(Map<String, dynamic> json) => StoreOwner(
    shopDetails: ShopDetails.fromJson(json["shopDetails"]),
    id: json["_id"],
    ownerName: json["ownerName"],
    accountStatus: json["accountStatus"],
  );

  Map<String, dynamic> toJson() => {
    "shopDetails": shopDetails.toJson(),
    "_id": id,
    "ownerName": ownerName,
    "accountStatus": accountStatus,
  };
}

class ShopDetails {
  ShopAddress shopAddress;
  Location location;
  WorkingHours workingHours;
  String shopName;
  String licenseNumber;
  String gstNumber;
  List<dynamic> shopImages;
  bool? isActive;
  bool? isVerified;

  ShopDetails({
    required this.shopAddress,
    required this.location,
    required this.workingHours,
    required this.shopName,
    required this.licenseNumber,
    required this.gstNumber,
    required this.shopImages,
    required this.isActive,
    required this.isVerified,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) => ShopDetails(
    shopAddress: ShopAddress.fromJson(json["shopAddress"]),
    location: Location.fromJson(json["location"]),
    workingHours: WorkingHours.fromJson(json["workingHours"]),
    shopName: json["shopName"],
    licenseNumber: json["licenseNumber"],
    gstNumber: json["gstNumber"],
    shopImages: List<dynamic>.from(json["shopImages"].map((x) => x)),
    isActive: json["isActive"],
    isVerified: json["isVerified"],
  );

  Map<String, dynamic> toJson() => {
    "shopAddress": shopAddress.toJson(),
    "location": location.toJson(),
    "workingHours": workingHours.toJson(),
    "shopName": shopName,
    "licenseNumber": licenseNumber,
    "gstNumber": gstNumber,
    "shopImages": List<dynamic>.from(shopImages.map((x) => x)),
    "isActive": isActive,
    "isVerified": isVerified,
  };
}

class Location {
  double latitude;
  double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class ShopAddress {
  String street;
  String city;
  String state;
  String pincode;

  ShopAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) => ShopAddress(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    pincode: json["pincode"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "pincode": pincode,
  };
}

class WorkingHours {
  String openTime;
  String closeTime;
  List<String> workingDays;

  WorkingHours({
    required this.openTime,
    required this.closeTime,
    required this.workingDays,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) => WorkingHours(
    openTime: json["openTime"],
    closeTime: json["closeTime"],
    workingDays: List<String>.from(json["workingDays"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "openTime": openTime,
    "closeTime": closeTime,
    "workingDays": List<dynamic>.from(workingDays.map((x) => x)),
  };
}

class Pagination {
  int currentPage;
  int totalPages;
  int totalMedicines;
  bool? hasNextPage;
  bool? hasPrevPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalMedicines,
    required this.hasNextPage,
    required this.hasPrevPage,
    required int totalCount,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalMedicines: json["totalMedicines"],
    hasNextPage: json["hasNextPage"],
    hasPrevPage: json["hasPrevPage"],
    totalCount: json["totalCount"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalMedicines": totalMedicines,
    "hasNextPage": hasNextPage,
    "hasPrevPage": hasPrevPage,
  };
}
