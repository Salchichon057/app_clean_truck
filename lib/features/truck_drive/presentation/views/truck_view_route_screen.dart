import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/active_truck_route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:comaslimpio/core/config/map_token.dart';

class TruckViewRouteScreen extends ConsumerStatefulWidget {
  const TruckViewRouteScreen({super.key});

  @override
  ConsumerState<TruckViewRouteScreen> createState() =>
      _TruckViewRouteScreenState();
}

class _TruckViewRouteScreenState extends ConsumerState<TruckViewRouteScreen> {
  final MapController mapController = MapController();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _mapReady = false;
  bool _sendingLocation = false;
  Timer? _sendTimer;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)
      return;
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((pos) {
          setState(() => _currentPosition = pos);
          if (_mapReady) {
            mapController.move(LatLng(pos.latitude, pos.longitude), 16);
          }
        });
    final pos = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = pos);
  }

  void _toggleSendLocation(bool value, String userId) {
    setState(() => _sendingLocation = value);
    _sendTimer?.cancel();
    if (value) {
      _sendLocation(userId);
      _sendTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _sendLocation(userId),
      );
    }
  }

  Future<void> _sendLocation(String userId) async {
    if (_currentPosition == null) return;
    await FirebaseFirestore.instance.collection('app_users').doc(userId).update(
      {
        'location': {
          'lat': _currentPosition!.latitude,
          'long': _currentPosition!.longitude,
        },
      },
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _sendTimer?.cancel();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(activeTruckRouteProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver mi ruta'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
        actions: [
          if (user != null)
            Row(
              children: [
                const Text(
                  'Enviar ubicación',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _sendingLocation,
                  activeColor: AppTheme.primary,
                  onChanged: (val) => _toggleSendLocation(val, user.uid),
                ),
              ],
            ),
        ],
      ),
      body: routeAsync.when(
        data: (route) {
          if (route == null) {
            return const Center(child: Text('No tienes una ruta asignada.'));
          }
          return FutureBuilder<String>(
            future: MapToken.getMapToken(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == 'No token found') {
                return const Center(child: Text('No se pudo cargar el mapa'));
              }
              final mapboxToken = snapshot.data!;
              final points = route.points
                  .map((e) => LatLng(e.lat, e.long))
                  .toList();
              final polyline = Polyline(
                points: points,
                color: AppTheme.primary,
                strokeWidth: 5,
              );
              LatLng initialCenter = points.isNotEmpty
                  ? points.first
                  : const LatLng(-11.9498, -77.0622);

              if (_currentPosition != null) {
                initialCenter = LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                );
              }

              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 16,
                  onMapReady: () => setState(() => _mapReady = true),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxToken',
                  ),
                  if (points.length > 1) PolylineLayer(polylines: [polyline]),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.red,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                ],
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
