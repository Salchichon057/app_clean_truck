import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:geolocator/geolocator.dart';

class MapLocationState {
  final Location? currentLocation;
  final Location? selectedLocation;
  final String? currentAddress;

  MapLocationState({
    this.currentLocation,
    this.selectedLocation,
    this.currentAddress,
  });

  MapLocationState copyWith({
    Location? currentLocation,
    Location? selectedLocation,
    String? currentAddress,
  }) {
    return MapLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentAddress: currentAddress ?? this.currentAddress,
    );
  }
}

class MapLocationNotifier extends StateNotifier<MapLocationState> {
  MapLocationNotifier() : super(MapLocationState()) {
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // Precisión alta
      distanceFilter:
          10,
    );

    // Obtener la ubicación actual
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
      );
    } catch (e) {
      state = state.copyWith(
        currentLocation: Location(lat: -12.0464, long: -77.0428),
        selectedLocation: Location(lat: -12.0464, long: -77.0428),
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
