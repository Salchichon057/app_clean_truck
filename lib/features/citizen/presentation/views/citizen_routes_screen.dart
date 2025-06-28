import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:comaslimpio/features/admin/presentation/providers/route_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/selected_route_provider.dart';

class CitizenRoutesScreen extends ConsumerWidget {
  const CitizenRoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(activeRoutesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas disponibles'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
        iconTheme: IconThemeData(color: AppTheme.primary),
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(child: Text('No hay rutas disponibles.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final route = routes[index];
              return GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Seleccionar ruta'),
                      content: Text(
                        '¿Quieres seleccionar la ruta "${route.routeName}"?',
                      ),
                      actionsPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Seleccionar'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref
                        .read(selectedRouteProvider.notifier)
                        .setRoute(route);
                    context.pop();
                  }
                },
                child: Card(
                  color: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primary,
                              child: const Icon(
                                Icons.alt_route,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                route.routeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Chip(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide.none,
                              ),
                              label: Text(
                                route.status == "active"
                                    ? "Activa"
                                    : "Inactiva",
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: route.status == "active"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 160,
                          child: FutureBuilder<String>(
                            future: MapToken.getMapToken(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data == 'No token found') {
                                return const Center(
                                  child: Text("No se pudo cargar el mapa"),
                                );
                              }
                              final mapboxToken = snapshot.data!;
                              final points = route.points
                                  .map<LatLng>((e) => LatLng(e.lat, e.long))
                                  .toList();
                              final polyline = Polyline(
                                points: points,
                                color: AppTheme.primary,
                                strokeWidth: 4,
                              );
                              final mapController = MapController();

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (points.length > 1) {
                                  final bounds = LatLngBounds.fromPoints(
                                    points,
                                  );
                                  mapController.fitCamera(
                                    CameraFit.bounds(
                                      bounds: bounds,
                                      padding: const EdgeInsets.all(40),
                                    ),
                                  );
                                } else if (points.length == 1) {
                                  mapController.move(points.first, 16);
                                }
                              });

                              return FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: points.isNotEmpty
                                      ? points.first
                                      : const LatLng(-11.9498, -77.0622),
                                  initialZoom: 14,
                                  interactionOptions: const InteractionOptions(
                                    flags:
                                        InteractiveFlag.pinchZoom |
                                        InteractiveFlag.drag,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                                  ),
                                  if (points.length > 1)
                                    PolylineLayer(polylines: [polyline]),
                                  MarkerLayer(
                                    markers: [
                                      for (int i = 0; i < points.length; i++)
                                        Marker(
                                          point: points[i],
                                          width: 36,
                                          height: 36,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                color: AppTheme.primary,
                                                size: 32,
                                              ),
                                              Positioned(
                                                top: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${i + 1}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme.primary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
