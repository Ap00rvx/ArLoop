import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/vendor/store_owner_services.dart';
import '../../models/vendor/store_owner.dart';
import '../../models/vendor/shop.dart';
import '../../models/vendor/auth_response.dart';

part 'store_owner_events.dart';
part 'store_owner_state.dart';

class StoreOwnerBloc extends Bloc<StoreOwnerEvent, StoreOwnerState> {
  final StoreOwnerService _storeOwnerService;

  StoreOwnerBloc({StoreOwnerService? storeOwnerService})
    : _storeOwnerService = storeOwnerService ?? StoreOwnerService(),
      super(const StoreOwnerState()) {
    on<InitialStoreOwnerEvent>(_initialStoreOwnerEvent);

    // Authentication events
    on<RegisterStoreOwnerEvent>(_registerStoreOwnerEvent);
    on<LoginStoreOwnerEvent>(_loginStoreOwnerEvent);
    on<LogoutStoreOwnerEvent>(_logoutStoreOwnerEvent);

    // Profile events
    on<GetStoreOwnerProfileEvent>(_getStoreOwnerProfileEvent);
    on<UpdateStoreOwnerProfileEvent>(_updateStoreOwnerProfileEvent);

    // Shop events
    on<UpdateShopStatusEvent>(_updateShopStatusEvent);

    // Public events
    on<GetNearbyStoresEvent>(_getNearbyStoresEvent);

    // Admin events
    on<GetAllStoreOwnersEvent>(_getAllStoreOwnersEvent);
    on<UpdateAccountStatusEvent>(_updateAccountStatusEvent);

    // Token management events
    on<SetAuthTokenEvent>(_setAuthTokenEvent);
    on<ClearAuthTokenEvent>(_clearAuthTokenEvent);
  }

  //* InitialStoreOwnerEvent
  Future<void> _initialStoreOwnerEvent(
    InitialStoreOwnerEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));

    try {
      // Initialize the service (loads stored token)
      await _storeOwnerService.initialize();

      // Check if we have a stored token and if it's valid
      final storedToken = await _storeOwnerService.getStoredToken();

      if (storedToken != null) {
        final isValid = await _storeOwnerService.isTokenValid();

        if (isValid) {
          // Token is valid, try to get profile
          final profileResponse = await _storeOwnerService.getProfile();

          if (profileResponse.isSuccess && profileResponse.data != null) {
            emit(
              state.copyWith(
                isLoading: false,
                isAuthenticated: true,
                token: storedToken,
                currentOwner: profileResponse.data!.owner,
                currentShop: profileResponse.data!.shop,
                message: 'Session restored successfully',
              ),
            );
          } else {
            // Profile fetch failed, clear token
            await _storeOwnerService.clearAuthToken();
            emit(
              state.copyWith(
                isLoading: false,
                isAuthenticated: false,
                message: 'Session expired',
              ),
            );
          }
        } else {
          // Token is invalid, clear it
          await _storeOwnerService.clearAuthToken();
          emit(
            state.copyWith(
              isLoading: false,
              isAuthenticated: false,
              message: 'Session expired',
            ),
          );
        }
      } else {
        // No stored token
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to initialize: ${e.toString()}',
        ),
      );
    }
  }

  //* RegisterStoreOwnerEvent
  Future<void> _registerStoreOwnerEvent(
    RegisterStoreOwnerEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));

    try {
      final response = await _storeOwnerService.register(event.request);

      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;

        if (authResponse.token != null) {
          await _storeOwnerService.setAuthToken(authResponse.token!);
        }

        emit(
          state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            token: authResponse.token,
            currentOwner: authResponse.owner,
            currentShop: authResponse.shop,
            message: authResponse.message,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, error: response.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Registration failed: ${e.toString()}',
        ),
      );
    }
  }

  //* LoginStoreOwnerEvent
  Future<void> _loginStoreOwnerEvent(
    LoginStoreOwnerEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, message: null));

    try {
      final response = await _storeOwnerService.login(event.request);

      if (response.isSuccess && response.data != null) {
        final authResponse = response.data!;

        if (authResponse.token != null) {
          await _storeOwnerService.setAuthToken(authResponse.token!);
        }

        emit(
          state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            token: authResponse.token,
            currentOwner: authResponse.owner,
            currentShop: authResponse.shop,
            message: authResponse.message,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, error: response.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Login failed: ${e.toString()}',
        ),
      );
    }
  }

  //* LogoutStoreOwnerEvent
  Future<void> _logoutStoreOwnerEvent(
    LogoutStoreOwnerEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    await _storeOwnerService.clearAuthToken();

    emit(
      state.copyWith(
        isAuthenticated: false,
        token: null,
        currentOwner: null,
        currentShop: null,
        message: 'Logged out successfully',
      ),
    );
  }

  //* GetStoreOwnerProfileEvent
  Future<void> _getStoreOwnerProfileEvent(
    GetStoreOwnerProfileEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(state.copyWith(isProfileLoading: true, error: null, message: null));

    try {
      final response = await _storeOwnerService.getProfile();

      if (response.isSuccess && response.data != null) {
        final profileResponse = response.data!;

        emit(
          state.copyWith(
            isProfileLoading: false,
            currentOwner: profileResponse.owner,
            currentShop: profileResponse.shop,
            message: profileResponse.message,
          ),
        );
      } else {
        emit(state.copyWith(isProfileLoading: false, error: response.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isProfileLoading: false,
          error: 'Failed to get profile: ${e.toString()}',
        ),
      );
    }
  }

  //* UpdateStoreOwnerProfileEvent
  Future<void> _updateStoreOwnerProfileEvent(
    UpdateStoreOwnerProfileEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(state.copyWith(isProfileUpdating: true, error: null, message: null));

    try {
      final response = await _storeOwnerService.updateProfile(event.updateData);

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            isProfileUpdating: false,
            currentOwner: response.data!,
            message: 'Profile updated successfully',
          ),
        );
      } else {
        emit(state.copyWith(isProfileUpdating: false, error: response.message));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isProfileUpdating: false,
          error: 'Failed to update profile: ${e.toString()}',
        ),
      );
    }
  }

  //* UpdateShopStatusEvent
  Future<void> _updateShopStatusEvent(
    UpdateShopStatusEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(
      state.copyWith(isShopStatusUpdating: true, error: null, message: null),
    );

    try {
      final response = await _storeOwnerService.updateShopStatus(
        operationalStatus: event.operationalStatus,
        statusMessage: event.statusMessage,
      );

      if (response.isSuccess && response.data != null) {
        emit(
          state.copyWith(
            isShopStatusUpdating: false,
            currentShop: response.data!,
            message: 'Shop status updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(isShopStatusUpdating: false, error: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isShopStatusUpdating: false,
          error: 'Failed to update shop status: ${e.toString()}',
        ),
      );
    }
  }

  //* GetNearbyStoresEvent
  Future<void> _getNearbyStoresEvent(
    GetNearbyStoresEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(
      state.copyWith(isNearbyStoresLoading: true, error: null, message: null),
    );

    try {
      final response = await _storeOwnerService.getNearbyStores(
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
      );

      if (response.isSuccess && response.data != null) {
        final nearbyResponse = response.data!;

        emit(
          state.copyWith(
            isNearbyStoresLoading: false,
            nearbyStores: nearbyResponse.stores,
            nearbyStoresCount: nearbyResponse.count,
            message: nearbyResponse.message,
          ),
        );
      } else {
        emit(
          state.copyWith(isNearbyStoresLoading: false, error: response.message),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isNearbyStoresLoading: false,
          error: 'Failed to get nearby stores: ${e.toString()}',
        ),
      );
    }
  }

  //* GetAllStoreOwnersEvent
  Future<void> _getAllStoreOwnersEvent(
    GetAllStoreOwnersEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(
      state.copyWith(isAllStoreOwnersLoading: true, error: null, message: null),
    );

    try {
      final response = await _storeOwnerService.getAllStoreOwners(
        page: event.page,
        limit: event.limit,
        status: event.status,
        city: event.city,
        verified: event.verified,
      );

      if (response.isSuccess && response.data != null) {
        final allOwnersResponse = response.data!;

        emit(
          state.copyWith(
            isAllStoreOwnersLoading: false,
            allStoreOwners: allOwnersResponse.data.owners,
            paginationInfo: allOwnersResponse.data.pagination,
            message: allOwnersResponse.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isAllStoreOwnersLoading: false,
            error: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isAllStoreOwnersLoading: false,
          error: 'Failed to get all store owners: ${e.toString()}',
        ),
      );
    }
  }

  //* UpdateAccountStatusEvent
  Future<void> _updateAccountStatusEvent(
    UpdateAccountStatusEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    emit(
      state.copyWith(isAccountStatusUpdating: true, error: null, message: null),
    );

    try {
      final response = await _storeOwnerService.updateAccountStatus(
        ownerId: event.ownerId,
        accountStatus: event.accountStatus,
        reason: event.reason,
      );

      if (response.isSuccess && response.data != null) {
        // Update the store owner in the list
        final updatedOwners = state.allStoreOwners.map((owner) {
          if (owner.id == event.ownerId) {
            return response.data!;
          }
          return owner;
        }).toList();

        emit(
          state.copyWith(
            isAccountStatusUpdating: false,
            allStoreOwners: updatedOwners,
            message: 'Account status updated successfully',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isAccountStatusUpdating: false,
            error: response.message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isAccountStatusUpdating: false,
          error: 'Failed to update account status: ${e.toString()}',
        ),
      );
    }
  }

  //* SetAuthTokenEvent
  Future<void> _setAuthTokenEvent(
    SetAuthTokenEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    await _storeOwnerService.setAuthToken(event.token);

    emit(state.copyWith(token: event.token, isAuthenticated: true));
  }

  //* ClearAuthTokenEvent
  Future<void> _clearAuthTokenEvent(
    ClearAuthTokenEvent event,
    Emitter<StoreOwnerState> emit,
  ) async {
    await _storeOwnerService.clearAuthToken();

    emit(
      state.copyWith(
        token: null,
        isAuthenticated: false,
        currentOwner: null,
        currentShop: null,
      ),
    );
  }
}
