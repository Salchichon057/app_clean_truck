import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/features/auth/presentation/providers/register_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:comaslimpio/core/components/map/location_permission_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Step2Location extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _inputLabel('Dirección'),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  addressController.text.isEmpty
                      ? 'Mueve el mapa para seleccionar una dirección'
                      : addressController.text,
                  style: TextStyle(color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.location_on, color: Colors.grey),
            ],
          ),
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
        // Widget para manejar permisos de ubicación
        const LocationPermissionWidget(),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
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
              final initialCenter =
                  mapLocationState.selectedLocation ??
                  mapLocationState.currentLocation ??
                  Location(lat: -12.0464, long: -77.0428);
              return Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        initialCenter.lat,
                        initialCenter.long,
                      ),
                      initialZoom: 18,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        scrollWheelVelocity: 0.06,
                        keyboardOptions: const KeyboardOptions(),
                        cursorKeyboardRotationOptions:
                            CursorKeyboardRotationOptions.disabled(),
                      ),
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd) {
                          final center = event.camera.center;
                          final newLocation = Location(
                            lat: center.latitude,
                            long: center.longitude,
                          );
                          ref
                              .read(mapLocationProvider.notifier)
                              .updateSelectedLocation(newLocation);
                          ref
                              .read(registerFormProvider.notifier)
                              .updateLocation(newLocation);
                          onReverseGeocode(newLocation);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                      ),
                    ],
                  ),
                  // Ícono fijo en el centro
                  const Icon(Icons.location_pin, color: Colors.red, size: 40),
                ],
              );
            },
          ),
        ),
      ],
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
