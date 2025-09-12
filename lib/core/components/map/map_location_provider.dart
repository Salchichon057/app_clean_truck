import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class MapLocationState {
  final Location? currentLocation;
  final Location? selectedLocation;
  final String? currentAddress;
  final LocationPermissionStatus permissionStatus;
  final bool isLoading;

  MapLocationState({
    this.currentLocation,
    this.selectedLocation,
    this.currentAddress,
    this.permissionStatus = LocationPermissionStatus.unknown,
    this.isLoading = false,
  });

  MapLocationState copyWith({
    Location? currentLocation,
    Location? selectedLocation,
    String? currentAddress,
    LocationPermissionStatus? permissionStatus,
    bool? isLoading,
  }) {
    return MapLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MapLocationNotifier extends StateNotifier<MapLocationState> {
  MapLocationNotifier() : super(MapLocationState()) {
    initLocation();
  }

  Future<void> initLocation() async {
    state = state.copyWith(isLoading: true);
    
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.serviceDisabled,
        isLoading: false,
        currentLocation: Location(lat: -12.0464, long: -77.0428),
        selectedLocation: Location(lat: -12.0464, long: -77.0428),
      );
      return;
    }

    // Verificar permisos existentes
    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        isLoading: false,
        currentLocation: Location(lat: -12.0464, long: -77.0428),
        selectedLocation: Location(lat: -12.0464, long: -77.0428),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.deniedForever,
        isLoading: false,
        currentLocation: Location(lat: -12.0464, long: -77.0428),
        selectedLocation: Location(lat: -12.0464, long: -77.0428),
      );
      return;
    }

    // Si tenemos permisos, obtener ubicación
    await _getCurrentLocation();
  }

  Future<void> requestLocationPermission() async {
    state = state.copyWith(isLoading: true);
    
    final permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.denied,
        isLoading: false,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        permissionStatus: LocationPermissionStatus.deniedForever,
        isLoading: false,
      );
      return;
    }

    // Si se concedió el permiso, obtener ubicación
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      final location = Location(
        lat: position.latitude,
        long: position.longitude,
      );
      state = state.copyWith(
        currentLocation: location,
        selectedLocation: location,
        permissionStatus: LocationPermissionStatus.granted,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        currentLocation: Location(lat: -12.0464, long: -77.0428),
        selectedLocation: Location(lat: -12.0464, long: -77.0428),
        permissionStatus: LocationPermissionStatus.granted,
        isLoading: false,
      );
    }
  }

  void updateSelectedLocation(Location newLocation) {
    state = state.copyWith(selectedLocation: newLocation);
  }

  void updateCurrentAddress(String address) {
    state = state.copyWith(currentAddress: address);
  }
}

final mapLocationProvider =
    StateNotifierProvider<MapLocationNotifier, MapLocationState>((ref) {
      return MapLocationNotifier();
    });
