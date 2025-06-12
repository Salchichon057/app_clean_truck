import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/config/map_token.dart';

class LocationMapPreview extends StatelessWidget {
  final Location location;
  final double height;
  final double borderRadius;

  const LocationMapPreview({
    super.key,
    required this.location,
    this.height = 160,
    this.borderRadius = 16,
  });

  bool _isValidLocation(Location location) {
    return location.lat.isFinite &&
        location.long.isFinite &&
        !location.lat.isNaN &&
        !location.long.isNaN &&
        location.lat.abs() > 0.0001 &&
        location.long.abs() > 0.0001;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: MapToken.getMapToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == 'No token found') {
          return SizedBox(
            height: height,
            child: const Center(child: Text("No se pudo cargar el mapa")),
          );
        }

        final mapboxToken = snapshot.data!;

        if (!_isValidLocation(location)) {
          return SizedBox(
            height: height,
            child: const Center(child: Text("Ubicación no disponible")),
          );
        }

        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(location.lat, location.long),
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(location.lat, location.long),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
