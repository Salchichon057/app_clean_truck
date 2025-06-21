import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_on_map_provider.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_on_map.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as my_route;
import 'package:comaslimpio/features/admin/presentation/providers/route_provider.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucksOnMapAsync = ref.watch(trucksOnMapStreamProvider);
    final routesAsync = ref.watch(activeRoutesStreamProvider);
    final userLocationState = ref.watch(mapLocationProvider);

    return Scaffold(
      body: _CitizenMapBody(
        trucksOnMapAsync: trucksOnMapAsync,
        routesAsync: routesAsync,
        userLocationState: userLocationState,
      ),
    );
  }
}

class _CitizenMapBody extends StatefulWidget {
  final AsyncValue<List<TruckOnMap>> trucksOnMapAsync;
  final AsyncValue<List<my_route.Route>> routesAsync;
  final MapLocationState userLocationState;

  const _CitizenMapBody({
    required this.trucksOnMapAsync,
    required this.routesAsync,
    required this.userLocationState,
  });

  @override
  State<_CitizenMapBody> createState() => _CitizenMapBodyState();
}

class _CitizenMapBodyState extends State<_CitizenMapBody> {
  final mapController = MapController();
  LatLng? _lastCentered;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CitizenMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final userLocation = widget.userLocationState.currentLocation;
    if (userLocation != null) {
      final userLatLng = LatLng(userLocation.lat, userLocation.long);
      // Solo centra si la ubicación cambió y no se ha centrado antes
      if (_lastCentered == null || _lastCentered != userLatLng) {
        mapController.move(userLatLng, 16);
        _lastCentered = userLatLng;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = widget.userLocationState.currentLocation;

    return Stack(
      children: [
        FutureBuilder<String>(
          future: MapToken.getMapToken(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == 'No token found') {
              return const Center(child: Text('No se pudo cargar el mapa'));
            }
            final mapboxToken = snapshot.data!;

            return widget.trucksOnMapAsync.when(
              data: (trucksOnMap) {
                return widget.routesAsync.when(
                  data: (routes) {
                    // 1. Filtrar camiones cercanos
                    final nearbyTrucks = trucksOnMap.where((truck) {
                      if (userLocation == null) {
                        return false;
                      }
                      final distance = Geolocator.distanceBetween(
                        userLocation.lat,
                        userLocation.long,
                        truck.driverUser.location.lat,
                        truck.driverUser.location.long,
                      );
                      return distance <= 200;
                    }).toList();

                    // 2. Filtrar rutas de camiones cercanos
                    final nearbyRoutes = routes.where((route) {
                      return nearbyTrucks.any(
                        (truck) =>
                            truck.truckDriver.uidUsers == route.idTruckDrivers,
                      );
                    }).toList();

                    // Centro inicial: ubicación del usuario, o Lima por defecto
                    LatLng initialCenter = const LatLng(-12.0464, -77.0428);
                    if (userLocation != null) {
                      initialCenter = LatLng(
                        userLocation.lat,
                        userLocation.long,
                      );
                    }

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: initialCenter,
                        initialZoom: 16,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                        ),
                        // Rutas activas de camiones cercanos
                        ...nearbyRoutes.map(
                          (route) => PolylineLayer(
                            polylines: [
                              Polyline(
                                points: route.points
                                    .map((loc) => LatLng(loc.lat, loc.long))
                                    .toList(),
                                color: Colors.green,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                        ),
                        // Camiones cercanos
                        MarkerLayer(
                          markers: [
                            // Marcadores de camiones
                            ...nearbyTrucks.map(
                              (item) => Marker(
                                point: LatLng(
                                  item.driverUser.location.lat,
                                  item.driverUser.location.long,
                                ),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.local_shipping,
                                  color: Colors.blue,
                                  size: 36,
                                ),
                              ),
                            ),
                            // Marcador del usuario (casa)
                            if (userLocation != null)
                              Marker(
                                point: LatLng(
                                  userLocation.lat,
                                  userLocation.long,
                                ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error cargando rutas: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error cargando camiones: $e')),
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
                  if (userLocation != null) {
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
