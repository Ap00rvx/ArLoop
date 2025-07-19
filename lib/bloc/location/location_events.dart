part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class GetCurrentLocationEvent extends LocationEvent {}

class RequestLocationPermissionEvent extends LocationEvent {}
