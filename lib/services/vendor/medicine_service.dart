import '../../config/api.dart';
import '../../models/vendor/medicine.dart';

class MedicineService {
  static final ApiClient _client = ApiClient();

  MedicineService._();



  // Set authentication token
  static void setAuthToken(String token) {
    _client.setAuthToken(token);
  }

  // Clear authentication token
  static void clearAuthToken() {
    _client.clearAuthToken();
  }

  /// Add new medicine to inventory
  static Future<ApiResponse<Medicine>> addMedicine({
    required String medicineName,
    required String genericName,
    required String manufacturer,
    required String category,
    required String therapeuticClass,
    required String composition,
    required String strength,
    required String dosageForm,
    String? brandName,
    String? description,
    bool prescriptionRequired = false,
    double? sellingPrice,
    double? mrp,
    double? costPrice,
    int? availableQuantity,
    int? minimumStockLevel,
    List<String>? keywords,
    Map<String, dynamic>? batchDetails,
    String? imageUrl,
    bool isVisible = true,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        'api/medicines/add',
        body: {
          'medicineName': medicineName,
          'genericName': genericName,
          'manufacturer': manufacturer,
          'category': category,
          'therapeuticClass': therapeuticClass,
          'composition': composition,
          'strength': strength,
          'dosageForm': dosageForm,
          if (brandName != null) 'brandName': brandName,
          if (description != null) 'description': description,
          'prescriptionRequired': prescriptionRequired,
          if (sellingPrice != null)
            'pricing': {
              'sellingPrice': sellingPrice,
              'mrp':
                  mrp ??
                  sellingPrice, // MRP is required, default to selling price if not provided
              if (costPrice != null) 'costPrice': costPrice,
            },
          if (availableQuantity != null || minimumStockLevel != null)
            'stock': {
              if (availableQuantity != null)
                'availableQuantity': availableQuantity,
              if (availableQuantity != null) 'totalQuantity': availableQuantity,
              if (minimumStockLevel != null)
                'minimumStockLevel': minimumStockLevel,
              'unit': 'Piece', // Required field - default to 'Piece'
            },
          if (keywords != null) 'keywords': keywords,
          if (batchDetails != null) 'batchDetails': batchDetails,
          if (imageUrl != null) 'imageUrl': imageUrl,
          'isVisible': isVisible,
        },
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicineData = response.data!['medicine'];
        return ApiResponse<Medicine>(
          data: Medicine.fromJson(medicineData),
          statusCode: response.statusCode,
          message: response.data!['message'] ?? 'Medicine added successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<Medicine>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<Medicine>(
        data: null,
        statusCode: 0,
        message: 'Failed to add medicine: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get all medicines for the store owner
  /// Get all medicines for the store owner
  static Future<ApiResponse<MedicinePaginatedResponse>> getOwnerMedicines({
    int page = 1,
    int limit = 10,
    String? category,
    String? status,
    String? search,
    String? therapeuticClass,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        if (search != null) 'search': search,
        if (therapeuticClass != null) 'therapeuticClass': therapeuticClass,
      };

      final response = await _client.get<Map<String, dynamic>>(
        'api/medicines/owner/all',
        queryParams: queryParams,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        print('Full response data: ${response.data}');
        print('Response data type: ${response.data.runtimeType}');

        // Handle different response structures from backend
        Map<String, dynamic> responseData;

        if (response.data!.containsKey('data')) {
          // If response has 'data' wrapper
          responseData = response.data!['data'] as Map<String, dynamic>;
        } else {
          // If response is direct data
          responseData = response.data!;
        }

        print('Extracted responseData: $responseData');
        print('ResponseData type: ${responseData.runtimeType}');

        // Ensure medicines is a List
        List<dynamic> medicinesJson;
        if (responseData.containsKey('medicines')) {
          final medicinesData = responseData['medicines'];
          if (medicinesData is List) {
            medicinesJson = medicinesData;
          } else {
            throw Exception(
              'Medicines data is not a List: ${medicinesData.runtimeType}',
            );
          }
        } else {
          throw Exception('No medicines field found in response');
        }

        print('Medicines JSON length: ${medicinesJson.length}');

        // Parse medicines list
        final medicines = medicinesJson.map((medicineJson) {
          if (medicineJson is Map<String, dynamic>) {
            return Medicine.fromJson(medicineJson as Map<String, dynamic>);
          } else {
            throw Exception(
              'Medicine item is not a Map: ${medicineJson.runtimeType}',
            );
          }
        }).toList();

        // Parse pagination info
        Map<String, dynamic> paginationJson;
        if (responseData.containsKey('pagination')) {
          final paginationData = responseData['pagination'];
          if (paginationData is Map<String, dynamic>) {
            paginationJson = paginationData;
          } else {
            throw Exception(
              'Pagination data is not a Map: ${paginationData.runtimeType}',
            );
          }
        } else {
          // Create default pagination if not provided
          paginationJson = {
            'currentPage': page,
            'totalPages': 1,
            'totalMedicines': medicines.length,
            'hasNextPage': false,
            'hasPrevPage': page > 1,
          };
        }

        final pagination = PaginationInfo.fromJson(paginationJson);
      print('Pagination info: $pagination');

        final model = MedicinePaginatedResponse(
          medicines: medicines,
          pagination: pagination,
        );

        print(
          "Successfully created MedicinePaginatedResponse with ${medicines.length} medicines",
        );

        return ApiResponse<MedicinePaginatedResponse>(
          data: model,
          statusCode: response.statusCode,
          message:
              response.data!['message'] ?? 'Medicines retrieved successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<MedicinePaginatedResponse>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      print('Error in getOwnerMedicines: $e');
      // print('Error stack trace: ${StackTrace.current}');
      return ApiResponse<MedicinePaginatedResponse>(
        data: null,
        statusCode: 0,
        message: 'Failed to get medicines: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Update medicine details
  static Future<ApiResponse<Medicine>> updateMedicine({
    required String medicineId,
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
    Map<String, dynamic>? pricing,
    Map<String, dynamic>? stock,
    List<String>? keywords,
    Map<String, dynamic>? batchDetails,
    String? imageUrl,
    bool? isVisible,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (medicineName != null) body['medicineName'] = medicineName;
      if (genericName != null) body['genericName'] = genericName;
      if (brandName != null) body['brandName'] = brandName;
      if (manufacturer != null) body['manufacturer'] = manufacturer;
      if (category != null) body['category'] = category;
      if (therapeuticClass != null) body['therapeuticClass'] = therapeuticClass;
      if (composition != null) body['composition'] = composition;
      if (strength != null) body['strength'] = strength;
      if (dosageForm != null) body['dosageForm'] = dosageForm;
      if (description != null) body['description'] = description;
      if (prescriptionRequired != null)
        body['prescriptionRequired'] = prescriptionRequired;
      if (pricing != null) body['pricing'] = pricing;
      if (stock != null) body['stock'] = stock;
      if (keywords != null) body['keywords'] = keywords;
      if (batchDetails != null) body['batchDetails'] = batchDetails;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (isVisible != null) body['isVisible'] = isVisible;
      if (status != null) body['status'] = status;

      final response = await _client.put<Map<String, dynamic>>(
        'api/medicines/$medicineId',
        body: body,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicineData = response.data!['medicine'];
        return ApiResponse<Medicine>(
          data: Medicine.fromJson(medicineData),
          statusCode: response.statusCode,
          message: response.data!['message'] ?? 'Medicine updated successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<Medicine>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<Medicine>(
        data: null,
        statusCode: 0,
        message: 'Failed to update medicine: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Delete medicine
  static Future<ApiResponse<void>> deleteMedicine(String medicineId) async {
    try {
      final response = await _client.delete<Map<String, dynamic>>(
        'api/medicines/$medicineId',
        fromJson: (json) => json,
      );

      return ApiResponse<void>(
        data: null,
        statusCode: response.statusCode,
        message: response.data?['message'] ?? 'Medicine deleted successfully',
        isSuccess: response.isSuccess,
        error: response.error,
      );
    } catch (e) {
      return ApiResponse<void>(
        data: null,
        statusCode: 0,
        message: 'Failed to delete medicine: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Search medicines (public endpoint)
  static Future<ApiResponse<MedicinePaginatedResponse>> searchMedicines({
    String? search,
    double? latitude,
    double? longitude,
    double radius = 10.0,
    String? category,
    String? therapeuticClass,
    bool? prescriptionRequired,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'radius': radius,
        if (search != null) 'search': search,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (category != null) 'category': category,
        if (therapeuticClass != null) 'therapeuticClass': therapeuticClass,
        if (prescriptionRequired != null)
          'prescriptionRequired': prescriptionRequired,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      };

      final response = await _client.get<Map<String, dynamic>>(
        'api/medicines/search',
        queryParams: queryParams,
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final responseData = response.data!['data'];
        return ApiResponse<MedicinePaginatedResponse>(
          data: MedicinePaginatedResponse.fromJson(responseData),
          statusCode: response.statusCode,
          message:
              response.data!['message'] ?? 'Medicines retrieved successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<MedicinePaginatedResponse>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<MedicinePaginatedResponse>(
        data: null,
        statusCode: 0,
        message: 'Failed to search medicines: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get medicine details by ID
  static Future<ApiResponse<Medicine>> getMedicineDetails(
    String medicineId,
  ) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        'api/medicines/$medicineId',
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicineData = response.data!['medicine'];
        return ApiResponse<Medicine>(
          data: Medicine.fromJson(medicineData),
          statusCode: response.statusCode,
          message:
              response.data!['message'] ??
              'Medicine details retrieved successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<Medicine>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<Medicine>(
        data: null,
        statusCode: 0,
        message: 'Failed to get medicine details: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Update medicine stock
  static Future<ApiResponse<Medicine>> updateStock({
    required String medicineId,
    required String operation, // 'add', 'remove', 'set'
    required int quantity,
    Map<String, dynamic>? batchDetails,
  }) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        'api/medicines/$medicineId/stock',
        body: {
          'operation': operation,
          'quantity': quantity,
          if (batchDetails != null) 'batchDetails': batchDetails,
        },
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicineData = response.data!['medicine'];
        return ApiResponse<Medicine>(
          data: Medicine.fromJson(medicineData),
          statusCode: response.statusCode,
          message: response.data!['message'] ?? 'Stock updated successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<Medicine>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<Medicine>(
        data: null,
        statusCode: 0,
        message: 'Failed to update stock: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get low stock medicines
  static Future<ApiResponse<List<Medicine>>> getLowStockMedicines() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        'api/medicines/owner/low-stock',
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicinesJson = response.data!['medicines'] as List;
        final medicines = medicinesJson
            .map((json) => Medicine.fromJson(json))
            .toList();

        return ApiResponse<List<Medicine>>(
          data: medicines,
          statusCode: response.statusCode,
          message:
              response.data!['message'] ??
              'Low stock medicines retrieved successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<List<Medicine>>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<List<Medicine>>(
        data: null,
        statusCode: 0,
        message: 'Failed to get low stock medicines: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get expired medicines
  static Future<ApiResponse<List<Medicine>>> getExpiredMedicines() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        'api/medicines/owner/expired',
        fromJson: (json) => json,
      );

      if (response.isSuccess && response.data != null) {
        final medicinesJson = response.data!['medicines'] as List;
        final medicines = medicinesJson
            .map((json) => Medicine.fromJson(json))
            .toList();

        return ApiResponse<List<Medicine>>(
          data: medicines,
          statusCode: response.statusCode,
          message:
              response.data!['message'] ??
              'Expired medicines retrieved successfully',
          isSuccess: true,
        );
      } else {
        return ApiResponse<List<Medicine>>(
          data: null,
          statusCode: response.statusCode,
          message: response.message,
          isSuccess: false,
          error: response.error,
        );
      }
    } catch (e) {
      return ApiResponse<List<Medicine>>(
        data: null,
        statusCode: 0,
        message: 'Failed to get expired medicines: $e',
        isSuccess: false,
        error: e,
      );
    }
  }

  /// Get medicine categories (helper method)
  static List<String> getMedicineCategories() {
    return [
      'Tablet',
      'Capsule',
      'Syrup',
      'Injection',
      'Drops',
      'Cream',
      'Ointment',
      'Powder',
      'Inhaler',
      'Spray',
      'Gel',
      'Lotion',
      'Suspension',
      'Other',
    ];
  }

  /// Get therapeutic classes (helper method)
  static List<String> getTherapeuticClasses() {
    return [
      'Antibiotic',
      'Analgesic',
      'Antacid',
      'Antidiabetic',
      'Antihypertensive',
      'Antihistamine',
      'Vitamin',
      'Supplement',
      'Cardiac',
      'Respiratory',
      'Gastrointestinal',
      'Neurological',
      'Dermatological',
      'Other',
    ];
  }

  /// Get dosage forms (helper method)
  static List<String> getDosageForms() {
    return [
      'Oral',
      'Topical',
      'Injectable',
      'Inhalation',
      'Nasal',
      'Ophthalmic',
      'Otic',
      'Rectal',
    ];
  }

  /// Get stock units (helper method)
  static List<String> getStockUnits() {
    return ['Piece', 'Strip', 'Bottle', 'Tube', 'Box', 'Vial', 'Packet'];
  }

  /// Get stock operations (helper method)
  static List<String> getStockOperations() {
    return ['add', 'remove', 'set'];
  }
}
