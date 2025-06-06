import 'package:comaslimpio/core/config/map_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart';

class Step2Location extends StatelessWidget {
  final TextEditingController addressController;
  final MapController mapController;
  final bool isDragging;
  final VoidCallback onConfirmLocation;
  final Future<void> Function(Location) onReverseGeocode;
  final MapLocationState mapLocationState;

  const Step2Location({
    super.key,
    required this.addressController,
    required this.mapController,
    required this.isDragging,
    required this.onConfirmLocation,
    required this.onReverseGeocode,
    required this.mapLocationState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputLabel('Dirección'),
        const SizedBox(height: 4),
        TextField(
          controller: addressController,
          decoration: _inputDecoration(hint: 'Ingresa tu dirección'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF0C3751),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: FutureBuilder<String>(
            future: MapToken.getMapToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == 'No token found') {
                return const Center(child: Text("Failed to load Map Token"));
              }

              final mapboxToken = snapshot.data!;

              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: mapLocationState.currentLocation != null
                      ? LatLng(
                          mapLocationState.currentLocation!.lat,
                          mapLocationState.currentLocation!.long,
                        )
                      : const LatLng(-12.0464, -77.0428),
                  initialZoom: 15.0,
                  onMapReady: () {
                    if (mapLocationState.currentLocation != null) {
                      mapController.move(
                        LatLng(
                          mapLocationState.currentLocation!.lat,
                          mapLocationState.currentLocation!.long,
                        ),
                        15.0,
                      );
                      onReverseGeocode(mapLocationState.currentLocation!);
                    }
                  },
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && !isDragging) {
                      // No hacemos nada mientras se arrastra
                    }
                  },
                  onMapEvent: (event) {
                    if (event.source == MapEventSource.dragEnd) {
                      final newLocation = Location(
                        lat: event.camera.center.latitude,
                        long: event.camera.center.longitude,
                      );
                      onReverseGeocode(newLocation);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                  ),
                  MarkerLayer(
                    markers: [
                      if (mapLocationState.currentLocation != null)
                        Marker(
                          point: LatLng(
                            mapLocationState.currentLocation!.lat,
                            mapLocationState.currentLocation!.long,
                          ),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      if (mapLocationState.selectedLocation != null)
                        Marker(
                          point: LatLng(
                            mapLocationState.selectedLocation!.lat,
                            mapLocationState.selectedLocation!.long,
                          ),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onConfirmLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3B56),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Hecho',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _inputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0C3751),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
