import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:iconsax/iconsax.dart';
import '../../../theme/colors.dart';

class LocationSelectorScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationSelectorScreen({super.key, this.initialLocation});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  LatLng _currentCenter = const LatLng(28.6139, 77.2090); // Default to Delhi
  String _selectedAddress = '';
  bool _isLoadingAddress = false;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _currentCenter = widget.initialLocation!;
      _getAddressFromCoordinates(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingCurrentLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      final currentLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentCenter = currentLocation;
        _selectedLocation = currentLocation;
      });

      _mapController.move(currentLocation, 15);

      await _getAddressFromCoordinates(
        currentLocation.latitude,
        currentLocation.longitude,
      );
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    } finally {
      setState(() => _isLoadingCurrentLocation = false);
    }
  }

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    setState(() => _isLoadingAddress = true);

    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _selectedAddress =
              [
                    placemark.street,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country,
                  ]
                  .where((element) => element != null && element.isNotEmpty)
                  .join(', ');
        });
      }
    } catch (e) {
      _showSnackBar('Error getting address: $e');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    setState(() {
      _selectedLocation = position.center;
    });
    _getAddressFromCoordinates(
      position.center.latitude,
      position.center.longitude,
    );
  }

  void _confirmLocation() async {
    if (_selectedLocation != null) {
      final result = <String, dynamic>{
        'location': _selectedLocation,
        'address': _selectedAddress,
      };

      // Parse address components
      await _parseAddressComponents(result);
      print(result);

      Navigator.pop(context, result);
    }
  }

   _parseAddressComponents(Map<String, dynamic> result) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        result['street'] = placemark.street ?? '';
        result['city'] = placemark.locality ?? '';
        result['state'] = placemark.administrativeArea ?? '';
        result['pincode'] = placemark.postalCode ?? '';
      }
    } catch (e) {
      print('Error parsing address components: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.gps),
            onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15,
              onPositionChanged: _onMapPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.arloop.arloop',
                maxZoom: 19,
              ),
            ],
          ),

          // Fixed pin at center
          const Icon(Iconsax.location5, color: AppColors.error, size: 40),

          // Loading indicator for current location
          if (_isLoadingCurrentLocation)
            const Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Getting current location...'),
                    ],
                  ),
                ),
              ),
            ),

          // Address display
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingAddress)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading address...'),
                        ],
                      )
                    else if (_selectedAddress.isNotEmpty)
                      Text(
                        _selectedAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkText,
                        ),
                      )
                    else
                      const Text(
                        'Move map to select a location',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.lightText,
                        ),
                      ),

                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.lightText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedLocation != null ? _confirmLocation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
