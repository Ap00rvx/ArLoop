import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/vendor/medicine.dart';
import '../../services/vendor/medicine_service.dart';

part 'medicine_events.dart';
part 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  MedicineBloc() : super(const MedicineState()) {
    on<InitialMedicineEvent>(_initialMedicineEvent);
    on<LoadOwnerMedicinesEvent>(_loadOwnerMedicinesEvent);
    on<AddMedicineEvent>(_addMedicineEvent);
    on<UpdateMedicineEvent>(_updateMedicineEvent);
    on<DeleteMedicineEvent>(_deleteMedicineEvent);
    on<SearchMedicinesEvent>(_searchMedicinesEvent);
    on<GetMedicineDetailsEvent>(_getMedicineDetailsEvent);
    on<UpdateStockEvent>(_updateStockEvent);
    on<LoadLowStockMedicinesEvent>(_loadLowStockMedicinesEvent);
    on<LoadExpiredMedicinesEvent>(_loadExpiredMedicinesEvent);
    on<SetAuthTokenEvent>(_setAuthTokenEvent);
    on<ClearAuthTokenEvent>(_clearAuthTokenEvent);
  }

  //* InitialMedicineEvent
  Future<void> _initialMedicineEvent(
    InitialMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    final token = await FlutterSecureStorage().read(key: "store_owner_token"); 
    if (token != null && token.isNotEmpty) {
      MedicineService.setAuthToken(token);
    }
    emit(state.copyWith(status: MedicineStatus.initial));
  }

  //* LoadOwnerMedicinesEvent
  Future<void> _loadOwnerMedicinesEvent(
    LoadOwnerMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.getOwnerMedicines(
        page: event.page,
        limit: event.limit,
        category: event.category,
        status: event.status,
        search: event.search,
        therapeuticClass: event.therapeuticClass,
      );

      if (response.isSuccess && response.data != null) {
        final paginatedResponse = response.data!;
        final isFirstPage = event.page == 1;
        final medicines = isFirstPage
            ? paginatedResponse.medicines
            : [...state.medicines, ...paginatedResponse.medicines];

        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: medicines,
            paginatedResponse: paginatedResponse,
            hasReachedMax: !paginatedResponse.pagination.hasNextPage,
            currentPage: event.page,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to load medicines: $e',
        ),
      );
    }
  }

  //* AddMedicineEvent
  Future<void> _addMedicineEvent(
    AddMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.addMedicine(
        medicineName: event.medicineName,
        genericName: event.genericName,
        manufacturer: event.manufacturer,
        category: event.category,
        therapeuticClass: event.therapeuticClass,
        composition: event.composition,
        strength: event.strength,
        dosageForm: event.dosageForm,
        brandName: event.brandName,
        description: event.description,
        prescriptionRequired: event.prescriptionRequired,
        sellingPrice: event.sellingPrice,
        mrp: event.mrp,
        costPrice: event.costPrice,
        availableQuantity: event.availableQuantity,
        minimumStockLevel: event.minimumStockLevel,
        keywords: event.keywords,
        batchDetails: event.batchDetails,
        imageUrl: event.imageUrl,
        isVisible: event.isVisible,
      );

      if (response.isSuccess && response.data != null) {
        final newMedicine = response.data!;
        final updatedMedicines = [newMedicine, ...state.medicines];

        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: updatedMedicines,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to add medicine: $e',
        ),
      );
    }
  }

  //* UpdateMedicineEvent
  Future<void> _updateMedicineEvent(
    UpdateMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.updateMedicine(
        medicineId: event.medicineId,
        medicineName: event.medicineName,
        genericName: event.genericName,
        brandName: event.brandName,
        manufacturer: event.manufacturer,
        category: event.category,
        therapeuticClass: event.therapeuticClass,
        composition: event.composition,
        strength: event.strength,
        dosageForm: event.dosageForm,
        description: event.description,
        prescriptionRequired: event.prescriptionRequired,
        pricing: event.pricing,
        stock: event.stock,
        keywords: event.keywords,
        batchDetails: event.batchDetails,
        imageUrl: event.imageUrl,
        isVisible: event.isVisible,
        status: event.status,
      );

      if (response.isSuccess && response.data != null) {
        final updatedMedicine = response.data!;
        final updatedMedicines = state.medicines.map((medicine) {
          return medicine.id == event.medicineId ? updatedMedicine : medicine;
        }).toList();

        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: updatedMedicines,
            selectedMedicine: updatedMedicine,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to update medicine: $e',
        ),
      );
    }
  }

  //* DeleteMedicineEvent
  Future<void> _deleteMedicineEvent(
    DeleteMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.deleteMedicine(event.medicineId);

      if (response.isSuccess) {
        final updatedMedicines = state.medicines
            .where((medicine) => medicine.id != event.medicineId)
            .toList();

        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: updatedMedicines,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to delete medicine: $e',
        ),
      );
    }
  }

  //* SearchMedicinesEvent
  Future<void> _searchMedicinesEvent(
    SearchMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.searchMedicines(
        search: event.search,
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
        category: event.category,
        therapeuticClass: event.therapeuticClass,
        prescriptionRequired: event.prescriptionRequired,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        page: event.page,
        limit: event.limit,
      );

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: MedicineStatus.success,
            searchResults: response.data!.medicines,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to search medicines: $e',
        ),
      );
    }
  }

  //* GetMedicineDetailsEvent
  Future<void> _getMedicineDetailsEvent(
    GetMedicineDetailsEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.getMedicineDetails(
        event.medicineId,
      );

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: MedicineStatus.success,
            selectedMedicine: response.data!,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to get medicine details: $e',
        ),
      );
    }
  }

  //* UpdateStockEvent
  Future<void> _updateStockEvent(
    UpdateStockEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.updateStock(
        medicineId: event.medicineId,
        operation: event.operation,
        quantity: event.quantity,
        batchDetails: event.batchDetails,
      );

      if (response.isSuccess && response.data != null) {
        final updatedMedicine = response.data!;
        final updatedMedicines = state.medicines.map((medicine) {
          return medicine.id == event.medicineId ? updatedMedicine : medicine;
        }).toList();

        emit(
          state.copyWith(
            status: MedicineStatus.success,
            medicines: updatedMedicines,
            selectedMedicine: updatedMedicine,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to update stock: $e',
        ),
      );
    }
  }

  //* LoadLowStockMedicinesEvent
  Future<void> _loadLowStockMedicinesEvent(
    LoadLowStockMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.getLowStockMedicines();

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: MedicineStatus.success,
            lowStockMedicines: response.data!,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to load low stock medicines: $e',
        ),
      );
    }
  }

  //* LoadExpiredMedicinesEvent
  Future<void> _loadExpiredMedicinesEvent(
    LoadExpiredMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MedicineStatus.loading));

      final response = await MedicineService.getExpiredMedicines();

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            status: MedicineStatus.success,
            expiredMedicines: response.data!,
            successMessage: response.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MedicineStatus.failure,
            errorMessage: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MedicineStatus.failure,
          errorMessage: 'Failed to load expired medicines: $e',
        ),
      );
    }
  }

  //* SetAuthTokenEvent
  Future<void> _setAuthTokenEvent(
    SetAuthTokenEvent event,
    Emitter<MedicineState> emit,
  ) async {
    MedicineService.setAuthToken(event.token);
    emit(
      state.copyWith(
        status: MedicineStatus.initial,
        successMessage: 'Authentication token set successfully',
      ),
    );
  }

  //* ClearAuthTokenEvent
  Future<void> _clearAuthTokenEvent(
    ClearAuthTokenEvent event,
    Emitter<MedicineState> emit,
  ) async {
    MedicineService.clearAuthToken();
    emit(const MedicineState()); // Reset to initial state
  }
}
