import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/core/models/location.dart';

class MapLocationState {
  final Location? currentLocation;
  final Location? selectedLocation;

  MapLocationState({this.currentLocation, this.selectedLocation});

  MapLocationState copyWith({
    Location? currentLocation,
    Location? selectedLocation,
  }) {
    return MapLocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

class MapLocationNotifier extends StateNotifier<MapLocationState> {
  MapLocationNotifier()
    : super(
        MapLocationState(
          currentLocation: Location(
            lat: -12.0464,
            long: -77.0428,
          ), // Comas, Perú por defecto
          selectedLocation: null,
        ),
      );

  void updateSelectedLocation(Location newLocation) {
    state = state.copyWith(selectedLocation: newLocation);
  }
}

final mapLocationProvider =
    StateNotifierProvider<MapLocationNotifier, MapLocationState>((ref) {
      return MapLocationNotifier();
    });
