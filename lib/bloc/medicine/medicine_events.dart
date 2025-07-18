part of 'medicine_bloc.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class InitialMedicineEvent extends MedicineEvent {}

class LoadOwnerMedicinesEvent extends MedicineEvent {
  final int page;
  final int limit;
  final String? category;
  final String? status;
  final String? search;
  final String? therapeuticClass;

  const LoadOwnerMedicinesEvent({
    this.page = 1,
    this.limit = 10,
    this.category,
    this.status,
    this.search,
    this.therapeuticClass,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    category,
    status,
    search,
    therapeuticClass,
  ];
}

class AddMedicineEvent extends MedicineEvent {
  final String medicineName;
  final String genericName;
  final String manufacturer;
  final String category;
  final String therapeuticClass;
  final String composition;
  final String strength;
  final String dosageForm;
  final String? brandName;
  final String? description;
  final bool prescriptionRequired;
  final double? sellingPrice;
  final double? mrp;
  final double? costPrice;
  final int? availableQuantity;
  final int? minimumStockLevel;
  final List<String>? keywords;
  final Map<String, dynamic>? batchDetails;
  final String? imageUrl;
  final bool isVisible;

  const AddMedicineEvent({
    required this.medicineName,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.therapeuticClass,
    required this.composition,
    required this.strength,
    required this.dosageForm,
    this.brandName,
    this.description,
    this.prescriptionRequired = false,
    this.sellingPrice,
    this.mrp,
    this.costPrice,
    this.availableQuantity,
    this.minimumStockLevel,
    this.keywords,
    this.batchDetails,
    this.imageUrl,
    this.isVisible = true,
  });

  @override
  List<Object?> get props => [
    medicineName,
    genericName,
    manufacturer,
    category,
    therapeuticClass,
    composition,
    strength,
    dosageForm,
    brandName,
    description,
    prescriptionRequired,
    sellingPrice,
    mrp,
    costPrice,
    availableQuantity,
    minimumStockLevel,
    keywords,
    batchDetails,
    imageUrl,
    isVisible,
  ];
}

class UpdateMedicineEvent extends MedicineEvent {
  final String medicineId;
  final String? medicineName;
  final String? genericName;
  final String? brandName;
  final String? manufacturer;
  final String? category;
  final String? therapeuticClass;
  final String? composition;
  final String? strength;
  final String? dosageForm;
  final String? description;
  final bool? prescriptionRequired;
  final Map<String, dynamic>? pricing;
  final Map<String, dynamic>? stock;
  final List<String>? keywords;
  final Map<String, dynamic>? batchDetails;
  final String? imageUrl;
  final bool? isVisible;
  final String? status;

  const UpdateMedicineEvent({
    required this.medicineId,
    this.medicineName,
    this.genericName,
    this.brandName,
    this.manufacturer,
    this.category,
    this.therapeuticClass,
    this.composition,
    this.strength,
    this.dosageForm,
    this.description,
    this.prescriptionRequired,
    this.pricing,
    this.stock,
    this.keywords,
    this.batchDetails,
    this.imageUrl,
    this.isVisible,
    this.status,
  });

  @override
  List<Object?> get props => [
    medicineId,
    medicineName,
    genericName,
    brandName,
    manufacturer,
    category,
    therapeuticClass,
    composition,
    strength,
    dosageForm,
    description,
    prescriptionRequired,
    pricing,
    stock,
    keywords,
    batchDetails,
    imageUrl,
    isVisible,
    status,
  ];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String medicineId;

  const DeleteMedicineEvent({required this.medicineId});

  @override
  List<Object> get props => [medicineId];
}

class SearchMedicinesEvent extends MedicineEvent {
  final String? search;
  final double? latitude;
  final double? longitude;
  final double radius;
  final String? category;
  final String? therapeuticClass;
  final bool? prescriptionRequired;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int limit;

  const SearchMedicinesEvent({
    this.search,
    this.latitude,
    this.longitude,
    this.radius = 10.0,
    this.category,
    this.therapeuticClass,
    this.prescriptionRequired,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [
    search,
    latitude,
    longitude,
    radius,
    category,
    therapeuticClass,
    prescriptionRequired,
    minPrice,
    maxPrice,
    page,
    limit,
  ];
}

class GetMedicineDetailsEvent extends MedicineEvent {
  final String medicineId;

  const GetMedicineDetailsEvent({required this.medicineId});

  @override
  List<Object> get props => [medicineId];
}

class UpdateStockEvent extends MedicineEvent {
  final String medicineId;
  final String operation; // 'add', 'remove', 'set'
  final int quantity;
  final Map<String, dynamic>? batchDetails;

  const UpdateStockEvent({
    required this.medicineId,
    required this.operation,
    required this.quantity,
    this.batchDetails,
  });

  @override
  List<Object?> get props => [medicineId, operation, quantity, batchDetails];
}

class LoadLowStockMedicinesEvent extends MedicineEvent {}

class LoadExpiredMedicinesEvent extends MedicineEvent {}

class SetAuthTokenEvent extends MedicineEvent {
  final String token;

  const SetAuthTokenEvent({required this.token});

  @override
  List<Object> get props => [token];
}

class ClearAuthTokenEvent extends MedicineEvent {}
