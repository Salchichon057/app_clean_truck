import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/services/geocoding_service.dart';
import 'package:comaslimpio/core/config/map_token.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart'
    as route_model;
import 'package:comaslimpio/features/admin/presentation/viewmodels/add_route_viewmodel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class AdminManageRoutesScreen extends ConsumerStatefulWidget {
  const AdminManageRoutesScreen({super.key});

  @override
  ConsumerState<AdminManageRoutesScreen> createState() =>
      _AdminManageRoutesScreenState();
}

class _AdminManageRoutesScreenState
    extends ConsumerState<AdminManageRoutesScreen> {
  final List<Location> _points = [];
  final List<String> _addresses = [];
  final TextEditingController _routeNameController = TextEditingController();
  String? _selectedTruckId;

  bool get _canSave =>
      _routeNameController.text.trim().isNotEmpty &&
      _points.length > 1 &&
      _selectedTruckId != null;

  Future<void> _addPoint(LatLng latLng) async {
    final newLocation = Location(lat: latLng.latitude, long: latLng.longitude);
    setState(() {
      _points.add(newLocation);
      _addresses.add('Obteniendo dirección...');
    });
    final mapboxToken = await MapToken.getMapToken();
    final address = await GeocodingService.getAddressFromLatLng(
      newLocation.lat,
      newLocation.long,
      mapboxToken,
    );
    setState(() {
      _addresses[_addresses.length - 1] = address;
    });
  }

  void _removePoint(int index) {
    setState(() {
      _points.removeAt(index);
      _addresses.removeAt(index);
    });
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trucksAsync = ref.watch(trucksStreamProvider);
    final addRouteState = ref.watch(addRouteViewModelProvider);
    final addRouteVM = ref.read(addRouteViewModelProvider.notifier);

    final markers = <Marker>[
      for (int i = 0; i < _points.length; i++)
        Marker(
          point: LatLng(_points[i].lat, _points[i].long),
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.location_on, color: AppTheme.primary, size: 38),
              Positioned(
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    ];

    final polyline = Polyline(
      points: _points.map((e) => LatLng(e.lat, e.long)).toList(),
      color: AppTheme.primary,
      strokeWidth: 4,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar una nueva ruta'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campos de nombre y camión
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _routeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la ruta',
                        prefixIcon: Icon(Icons.drive_file_rename_outline),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    trucksAsync.when(
                      data: (trucks) {
                        if (trucks.isEmpty) {
                          return const Text('No hay camiones registrados.');
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedTruckId,
                          items: trucks
                              .map(
                                (truck) => DropdownMenuItem<String>(
                                  value: truck.idTruck,
                                  child: Text(
                                    '${truck.idTruck} - ${truck.brand} ${truck.model}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTruckId = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Asignar camión',
                            prefixIcon: Icon(Icons.local_shipping),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text('Error cargando camiones: $e'),
                    ),
                  ],
                ),
              ),
              // Mapa (media pantalla)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
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
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: _points.isNotEmpty
                            ? LatLng(_points.last.lat, _points.last.long)
                            : LatLng(-11.9498, -77.0622), // Centro por defecto
                        initialZoom: 14,
                        onTap: (tapPosition, latLng) => _addPoint(latLng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                        ),
                        if (_points.length > 1)
                          PolylineLayer(polylines: [polyline]),
                        MarkerLayer(markers: markers),
                      ],
                    );
                  },
                ),
              ),
              // Tabla de puntos
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puntos de la ruta:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_points.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Haz clic en el mapa para agregar puntos.',
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _points.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 15),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removePoint(index),
                            ),
                          );
                        },
                      ),
                    if (addRouteState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          addRouteState.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              // Botón guardar ruta al final de todo
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _canSave && !addRouteState.isLoading
                        ? () async {
                            final newRoute = route_model.Route(
                              uid: '', // Firestore generará el ID
                              idTruck: _selectedTruckId!,
                              routeName: _routeNameController.text.trim(),
                              points: List<Location>.from(_points),
                              status: 'active',
                              date: Timestamp.now(),
                            );
                            await addRouteVM.addRoute(newRoute);
                            if (ref.read(addRouteViewModelProvider).success &&
                                mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                    child: addRouteState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Guardar ruta'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
