part of 'store_owner_bloc.dart';

class StoreOwnerState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? message;

  // Authentication
  final bool isAuthenticated;
  final String? token;
  final StoreOwner? currentOwner;
  final Shop? currentShop;

  // Profile
  final bool isProfileLoading;
  final bool isProfileUpdating;

  // Shop
  final bool isShopStatusUpdating;

  // Nearby stores
  final bool isNearbyStoresLoading;
  final List<StoreOwner> nearbyStores;
  final int nearbyStoresCount;

  // Admin
  final bool isAllStoreOwnersLoading;
  final List<StoreOwner> allStoreOwners;
  final PaginationInfo? paginationInfo;
  final bool isAccountStatusUpdating;

  const StoreOwnerState({
    this.isLoading = false,
    this.error,
    this.message,
    this.isAuthenticated = false,
    this.token,
    this.currentOwner,
    this.currentShop,
    this.isProfileLoading = false,
    this.isProfileUpdating = false,
    this.isShopStatusUpdating = false,
    this.isNearbyStoresLoading = false,
    this.nearbyStores = const [],
    this.nearbyStoresCount = 0,
    this.isAllStoreOwnersLoading = false,
    this.allStoreOwners = const [],
    this.paginationInfo,
    this.isAccountStatusUpdating = false,
  });

  StoreOwnerState copyWith({
    bool? isLoading,
    String? error,
    String? message,
    bool? isAuthenticated,
    String? token,
    StoreOwner? currentOwner,
    Shop? currentShop,
    bool? isProfileLoading,
    bool? isProfileUpdating,
    bool? isShopStatusUpdating,
    bool? isNearbyStoresLoading,
    List<StoreOwner>? nearbyStores,
    int? nearbyStoresCount,
    bool? isAllStoreOwnersLoading,
    List<StoreOwner>? allStoreOwners,
    PaginationInfo? paginationInfo,
    bool? isAccountStatusUpdating,
  }) {
    return StoreOwnerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      currentOwner: currentOwner ?? this.currentOwner,
      currentShop: currentShop ?? this.currentShop,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
      isShopStatusUpdating: isShopStatusUpdating ?? this.isShopStatusUpdating,
      isNearbyStoresLoading:
          isNearbyStoresLoading ?? this.isNearbyStoresLoading,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      nearbyStoresCount: nearbyStoresCount ?? this.nearbyStoresCount,
      isAllStoreOwnersLoading:
          isAllStoreOwnersLoading ?? this.isAllStoreOwnersLoading,
      allStoreOwners: allStoreOwners ?? this.allStoreOwners,
      paginationInfo: paginationInfo ?? this.paginationInfo,
      isAccountStatusUpdating:
          isAccountStatusUpdating ?? this.isAccountStatusUpdating,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    message,
    isAuthenticated,
    token,
    currentOwner,
    currentShop,
    isProfileLoading,
    isProfileUpdating,
    isShopStatusUpdating,
    isNearbyStoresLoading,
    nearbyStores,
    nearbyStoresCount,
    isAllStoreOwnersLoading,
    allStoreOwners,
    paginationInfo,
    isAccountStatusUpdating,
  ];
}
