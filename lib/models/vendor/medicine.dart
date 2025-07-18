class Medicine {
  final String id;
  final String medicineName;
  final String genericName;
  final String? brandName;
  final String manufacturer;
  final String category;
  final String therapeuticClass;
  final String composition;
  final String strength;
  final String dosageForm;
  final String? description;
  final bool prescriptionRequired;
  final String status;
  final bool isVisible;
  final MedicinePricing pricing;
  final MedicineStock stock;
  final List<String> keywords;
  final List<MedicineBatch>? batchDetails;
  final String? imageUrl;
  final String storeOwner;
  final double averageRating;
  final int totalSold;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.medicineName,
    required this.genericName,
    this.brandName,
    required this.manufacturer,
    required this.category,
    required this.therapeuticClass,
    required this.composition,
    required this.strength,
    required this.dosageForm,
    this.description,
    this.prescriptionRequired = false,
    this.status = 'active',
    this.isVisible = true,
    required this.pricing,
    required this.stock,
    this.keywords = const [],
    this.batchDetails,
    this.imageUrl,
    required this.storeOwner,
    this.averageRating = 0.0,
    this.totalSold = 0,
    this.totalReviews = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'] ?? json['id'] ?? '',
      medicineName: json['medicineName'] ?? '',
      genericName: json['genericName'] ?? '',
      brandName: json['brandName'],
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      therapeuticClass: json['therapeuticClass'] ?? '',
      composition: json['composition'] ?? '',
      strength: json['strength'] ?? '',
      dosageForm: json['dosageForm'] ?? '',
      description: json['description'],
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      status: json['status'] ?? 'active',
      isVisible: json['isVisible'] ?? true,
      pricing: MedicinePricing.fromJson(json['pricing'] ?? {}),
      stock: MedicineStock.fromJson(json['stock'] ?? {}),
      keywords: List<String>.from(json['keywords'] ?? []),
      batchDetails: json['batchDetails'] != null
          ? (json['batchDetails'] as List)
              .map((batch) => MedicineBatch.fromJson(batch))
              .toList()
          : null,
      imageUrl: json['imageUrl'],
      storeOwner: json['storeOwner'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalSold: json['totalSold'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'medicineName': medicineName,
      'genericName': genericName,
      'brandName': brandName,
      'manufacturer': manufacturer,
      'category': category,
      'therapeuticClass': therapeuticClass,
      'composition': composition,
      'strength': strength,
      'dosageForm': dosageForm,
      'description': description,
      'prescriptionRequired': prescriptionRequired,
      'status': status,
      'isVisible': isVisible,
      'pricing': pricing.toJson(),
      'stock': stock.toJson(),
      'keywords': keywords,
      'batchDetails': batchDetails?.map((batch) => batch.toJson()).toList(),
      'imageUrl': imageUrl,
      'storeOwner': storeOwner,
      'averageRating': averageRating,
      'totalSold': totalSold,
      'totalReviews': totalReviews,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Medicine copyWith({
    String? id,
    String? medicineName,
    String? genericName,
    String? brandName,
    String? manufacturer,
    String? category,
    String? therapeuticClass,
    String? composition,
    String? strength,
    String? dosageForm,
    String? description,
    bool? prescriptionRequired,
    String? status,
    bool? isVisible,
    MedicinePricing? pricing,
    MedicineStock? stock,
    List<String>? keywords,
    List<MedicineBatch>? batchDetails,
    String? imageUrl,
    String? storeOwner,
    double? averageRating,
    int? totalSold,
    int? totalReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      genericName: genericName ?? this.genericName,
      brandName: brandName ?? this.brandName,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      therapeuticClass: therapeuticClass ?? this.therapeuticClass,
      composition: composition ?? this.composition,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      description: description ?? this.description,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      status: status ?? this.status,
      isVisible: isVisible ?? this.isVisible,
      pricing: pricing ?? this.pricing,
      stock: stock ?? this.stock,
      keywords: keywords ?? this.keywords,
      batchDetails: batchDetails ?? this.batchDetails,
      imageUrl: imageUrl ?? this.imageUrl,
      storeOwner: storeOwner ?? this.storeOwner,
      averageRating: averageRating ?? this.averageRating,
      totalSold: totalSold ?? this.totalSold,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MedicinePricing {
  final double sellingPrice;
  final double? mrp;
  final double? costPrice;
  final double? discount;
  final String? discountType;

  MedicinePricing({
    required this.sellingPrice,
    this.mrp,
    this.costPrice,
    this.discount,
    this.discountType,
  });

  factory MedicinePricing.fromJson(Map<String, dynamic> json) {
    return MedicinePricing(
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      mrp: json['mrp']?.toDouble(),
      costPrice: json['costPrice']?.toDouble(),
      discount: json['discount']?.toDouble(),
      discountType: json['discountType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sellingPrice': sellingPrice,
      'mrp': mrp,
      'costPrice': costPrice,
      'discount': discount,
      'discountType': discountType,
    };
  }
}

class MedicineStock {
  final int availableQuantity;
  final int reservedQuantity;
  final int totalQuantity;
  final int minimumStockLevel;
  final String unit;

  MedicineStock({
    this.availableQuantity = 0,
    this.reservedQuantity = 0,
    this.totalQuantity = 0,
    this.minimumStockLevel = 10,
    this.unit = 'pieces',
  });

  factory MedicineStock.fromJson(Map<String, dynamic> json) {
    return MedicineStock(
      availableQuantity: json['availableQuantity'] ?? 0,
      reservedQuantity: json['reservedQuantity'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      minimumStockLevel: json['minimumStockLevel'] ?? 10,
      unit: json['unit'] ?? 'pieces',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableQuantity': availableQuantity,
      'reservedQuantity': reservedQuantity,
      'totalQuantity': totalQuantity,
      'minimumStockLevel': minimumStockLevel,
      'unit': unit,
    };
  }
}

class MedicineBatch {
  final String batchNumber;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final String? supplier;
  final double? purchasePrice;

  MedicineBatch({
    required this.batchNumber,
    required this.manufacturingDate,
    required this.expiryDate,
    this.supplier,
    this.purchasePrice,
  });

  factory MedicineBatch.fromJson(Map<String, dynamic> json) {
    return MedicineBatch(
      batchNumber: json['batchNumber'] ?? '',
      manufacturingDate: json['manufacturingDate'] != null
          ? DateTime.parse(json['manufacturingDate'])
          : DateTime.now(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : DateTime.now().add(const Duration(days: 365)),
      supplier: json['supplier'],
      purchasePrice: json['purchasePrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchNumber': batchNumber,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'supplier': supplier,
      'purchasePrice': purchasePrice,
    };
  }
}

class MedicinePaginatedResponse {
  final List<Medicine> medicines;
  final PaginationInfo pagination;

  MedicinePaginatedResponse({
    required this.medicines,
    required this.pagination,
  });
// ...existing code...

factory MedicinePaginatedResponse.fromJson(Map<String, dynamic> json) {
  print("MedicinePaginatedResponse.fromJson input: $json");
  print("Input type: ${json.runtimeType}");
  
  try {
    // Parse pagination info
    Map<String, dynamic> paginationJson;
    if (json.containsKey('pagination') && json['pagination'] is Map<String, dynamic>) {
      paginationJson = json['pagination'] as Map<String, dynamic>;
    } else {
      // Create default pagination
      paginationJson = {
        'currentPage': 1,
        'totalPages': 1,
        'totalMedicines': 0,
        'hasNextPage': false,
        'hasPrevPage': false,
      };
    }
    
    final pagination = PaginationInfo.fromJson(paginationJson);
    print("Parsed pagination: $pagination");
    
    // Parse medicines list
    List<Medicine> medicines = [];
    if (json.containsKey('medicines')) {
      final medicinesData = json['medicines'];
      print("Medicines data type: ${medicinesData.runtimeType}");
      
      if (medicinesData is List) {
        medicines = medicinesData.map((medicineJson) {
          if (medicineJson is Map<String, dynamic>) {
            return Medicine.fromJson(medicineJson);
          } else {
            print("Warning: Medicine item is not a Map: ${medicineJson.runtimeType}");
            return null;
          }
        }).where((medicine) => medicine != null).cast<Medicine>().toList();
      } else {
        print("Warning: Medicines data is not a List: ${medicinesData.runtimeType}");
      }
    }
    
    print("Parsed ${medicines.length} medicines");
    
    return MedicinePaginatedResponse(
      medicines: medicines,
      pagination: pagination,
    );
  } catch (e) {
    print("Error parsing MedicinePaginatedResponse: $e");
    rethrow;
  }
}

// ...existing code...
  Map<String, dynamic> toJson() {
    return {
      'medicines': medicines.map((medicine) => medicine.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalMedicines;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalMedicines,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalMedicines: json['totalMedicines'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalMedicines': totalMedicines,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
