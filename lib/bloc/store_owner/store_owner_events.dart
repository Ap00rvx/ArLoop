part of 'store_owner_bloc.dart';

abstract class StoreOwnerEvent extends Equatable {
  const StoreOwnerEvent();

  @override
  List<Object?> get props => [];
}

class InitialStoreOwnerEvent extends StoreOwnerEvent {
  const InitialStoreOwnerEvent();
}

// Authentication Events
class RegisterStoreOwnerEvent extends StoreOwnerEvent {
  final StoreOwnerRegistrationRequest request;

  const RegisterStoreOwnerEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class LoginStoreOwnerEvent extends StoreOwnerEvent {
  final StoreOwnerLoginRequest request;

  const LoginStoreOwnerEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class LogoutStoreOwnerEvent extends StoreOwnerEvent {
  const LogoutStoreOwnerEvent();
}

// Profile Events
class GetStoreOwnerProfileEvent extends StoreOwnerEvent {
  const GetStoreOwnerProfileEvent();
}

class UpdateStoreOwnerProfileEvent extends StoreOwnerEvent {
  final Map<String, dynamic> updateData;

  const UpdateStoreOwnerProfileEvent(this.updateData);

  @override
  List<Object?> get props => [updateData];
}

// Shop Events
class UpdateShopStatusEvent extends StoreOwnerEvent {
  final String? operationalStatus;
  final String? statusMessage;

  const UpdateShopStatusEvent({this.operationalStatus, this.statusMessage});

  @override
  List<Object?> get props => [operationalStatus, statusMessage];
}

// Public Events
class GetNearbyStoresEvent extends StoreOwnerEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const GetNearbyStoresEvent({
    required this.latitude,
    required this.longitude,
    this.radius = 10,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

// Admin Events
class GetAllStoreOwnersEvent extends StoreOwnerEvent {
  final int page;
  final int limit;
  final String? status;
  final String? city;
  final bool? verified;

  const GetAllStoreOwnersEvent({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.city,
    this.verified,
  });

  @override
  List<Object?> get props => [page, limit, status, city, verified];
}

class UpdateAccountStatusEvent extends StoreOwnerEvent {
  final String ownerId;
  final String accountStatus;
  final String? reason;

  const UpdateAccountStatusEvent({
    required this.ownerId,
    required this.accountStatus,
    this.reason,
  });

  @override
  List<Object?> get props => [ownerId, accountStatus, reason];
}

// Token Management Events
class SetAuthTokenEvent extends StoreOwnerEvent {
  final String token;

  const SetAuthTokenEvent(this.token);

  @override
  List<Object?> get props => [token];
}

class ClearAuthTokenEvent extends StoreOwnerEvent {
  const ClearAuthTokenEvent();
}
