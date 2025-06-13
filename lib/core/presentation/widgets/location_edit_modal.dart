import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class LocationEditModal extends StatefulWidget {
  final Location? initialLocation;

  const LocationEditModal({super.key, this.initialLocation});

  @override
  State<LocationEditModal> createState() => _LocationEditModalState();
}

class _LocationEditModalState extends State<LocationEditModal> {
  late MapController _mapController;
  late Location _selectedLocation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation =
        widget.initialLocation ??
        Location(lat: -12.0464, long: -77.0428); // Lima por defecto
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.edit_location, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Editar ubicación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Arrastra el mapa para seleccionar tu ubicación',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Mapa
            Expanded(
              child: FutureBuilder<String>(
                future: MapToken.getMapToken(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 'No token found') {
                    return const Center(
                      child: Text('No se pudo cargar el mapa'),
                    );
                  }

                  final mapboxToken = snapshot.data!;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              _selectedLocation.lat,
                              _selectedLocation.long,
                            ),
                            initialZoom: 17,
                            onMapEvent: (event) {
                              if (event is MapEventMoveStart) {
                                setState(() => _isDragging = true);
                              }
                              if (event is MapEventMoveEnd) {
                                setState(() => _isDragging = false);
                                final center = event.camera.center;
                                _selectedLocation = Location(
                                  lat: center.latitude,
                                  long: center.longitude,
                                );
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
                        // Pin fijo en el centro
                        IgnorePointer(
                          child: AnimatedScale(
                            scale: _isDragging ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_selectedLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
