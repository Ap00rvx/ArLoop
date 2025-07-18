part of 'medicine_bloc.dart';

enum MedicineStatus { initial, loading, success, failure }

class MedicineState extends Equatable {
  final MedicineStatus status;
  final List<Medicine> medicines;
  final Medicine? selectedMedicine;
  final MedicinePaginatedResponse? paginatedResponse;
  final List<Medicine> lowStockMedicines;
  final List<Medicine> expiredMedicines;
  final List<Medicine> searchResults;
  final String? errorMessage;
  final String? successMessage;
  final bool hasReachedMax;
  final int currentPage;

  const MedicineState({
    this.status = MedicineStatus.initial,
    this.medicines = const [],
    this.selectedMedicine,
    this.paginatedResponse,
    this.lowStockMedicines = const [],
    this.expiredMedicines = const [],
    this.searchResults = const [],
    this.errorMessage,
    this.successMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [
    status,
    medicines,
    selectedMedicine,
    paginatedResponse,
    lowStockMedicines,
    expiredMedicines,
    searchResults,
    errorMessage,
    successMessage,
    hasReachedMax,
    currentPage,
  ];

  bool get isInitial => status == MedicineStatus.initial;
  bool get isLoading => status == MedicineStatus.loading;
  bool get isSuccess => status == MedicineStatus.success;
  bool get isFailure => status == MedicineStatus.failure;

  MedicineState copyWith({
    MedicineStatus? status,
    List<Medicine>? medicines,
    Medicine? selectedMedicine,
    MedicinePaginatedResponse? paginatedResponse,
    List<Medicine>? lowStockMedicines,
    List<Medicine>? expiredMedicines,
    List<Medicine>? searchResults,
    String? errorMessage,
    String? successMessage,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return MedicineState(
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      selectedMedicine: selectedMedicine ?? this.selectedMedicine,
      paginatedResponse: paginatedResponse ?? this.paginatedResponse,
      lowStockMedicines: lowStockMedicines ?? this.lowStockMedicines,
      expiredMedicines: expiredMedicines ?? this.expiredMedicines,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  MedicineState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }
}
