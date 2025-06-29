import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as my_route;
import 'package:comaslimpio/features/admin/presentation/providers/route_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/selected_route_provider.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(activeRoutesStreamProvider);
    final userLocationState = ref.watch(mapLocationProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Ciudadano'),
        foregroundColor: AppTheme.primary,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route, color: AppTheme.primary),
            tooltip: selectedRoute != null
                ? 'Ruta: ${selectedRoute.routeName}'
                : 'Seleccionar ruta',
            onPressed: () {
              // Redirige a la pantalla de rutas
              context.push('/citizen/routes');
            },
          ),
        ],
      ),
      body: _CitizenMapBody(
        routesAsync: routesAsync,
        userLocationState: userLocationState,
      ),
    );
  }
}

class _CitizenMapBody extends ConsumerStatefulWidget {
  final AsyncValue<List<my_route.Route>> routesAsync;
  final MapLocationState userLocationState;

  const _CitizenMapBody({
    required this.routesAsync,
    required this.userLocationState,
  });

  @override
  ConsumerState<_CitizenMapBody> createState() => _CitizenMapBodyState();
}

class _CitizenMapBodyState extends ConsumerState<_CitizenMapBody> {
  final mapController = MapController();
  LatLng? _lastCentered;
  bool _mapReady = false;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _centerOnUser() {
    final userLocation = widget.userLocationState.currentLocation;
    if (userLocation != null && _mapReady) {
      final userLatLng = LatLng(userLocation.lat, userLocation.long);
      mapController.move(userLatLng, 16);
      _lastCentered = userLatLng;
    }
  }

  @override
  void didUpdateWidget(covariant _CitizenMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final userLocation = widget.userLocationState.currentLocation;
    if (userLocation != null && _mapReady) {
      final userLatLng = LatLng(userLocation.lat, userLocation.long);
      if (_lastCentered == null || _lastCentered != userLatLng) {
        mapController.move(userLatLng, 16);
        _lastCentered = userLatLng;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = widget.userLocationState.currentLocation;
    final selectedRoute = ref.watch(selectedRouteProvider);

    if (selectedRoute == null) {
      return const Center(
        child: Text(
          'Selecciona una ruta para ver el mapa',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        FutureBuilder<String>(
          future: MapToken.getMapToken(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == 'No token found') {
              return const Center(child: Text('No se pudo cargar el mapa'));
            }
            final mapboxToken = snapshot.data!;

            return widget.routesAsync.when(
              data: (routes) {
                final route = selectedRoute;

                LatLng initialCenter = const LatLng(-12.0464, -77.0428);
                if (userLocation != null) {
                  initialCenter = LatLng(userLocation.lat, userLocation.long);
                } else if (route.points.isNotEmpty) {
                  initialCenter = LatLng(
                    route.points.first.lat,
                    route.points.first.long,
                  );
                }

                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 16,
                    onMapReady: () {
                      _mapReady = true;
                      _centerOnUser();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                    ),
                    if (route.points.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: route.points
                                .map((loc) => LatLng(loc.lat, loc.long))
                                .toList(),
                            color: Colors.amber.shade800,
                            strokeWidth: 5,
                          ),
                        ],
                      ),
                    if (userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(userLocation.lat, userLocation.long),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.home,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cargando rutas: $e')),
            );
          },
        ),
        Positioned(
          bottom: 32,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RawMaterialButton(
                onPressed: () => context.push('/report-incident'),
                fillColor: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              const SizedBox(height: 16),
              RawMaterialButton(
                onPressed: () {
                  if (userLocation != null && _mapReady) {
                    mapController.move(
                      LatLng(userLocation.lat, userLocation.long),
                      16,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ubicación no disponible')),
                    );
                  }
                },
                fillColor: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
