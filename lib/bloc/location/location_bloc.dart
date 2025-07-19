import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';

part 'location_events.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        emit(
          LocationLoaded(
            latitude: position.latitude,
            longitude: position.longitude,
            address: address,
          ),
        );
      } else {
        emit(
          const LocationError(
            'Failed to get current location. Please check permissions.',
          ),
        );
      }
    } catch (e) {
      emit(LocationError('Error getting location: $e'));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationPermissionRequesting());

    try {
      final hasPermission = await LocationService.requestLocationPermission();
      if (hasPermission) {
        emit(LocationPermissionGranted());
        // Automatically get current location after permission is granted
        add(GetCurrentLocationEvent());
      } else {
        emit(const LocationPermissionDenied());
      }
    } catch (e) {
      emit(LocationError('Error requesting location permission: $e'));
    }
  }
}
