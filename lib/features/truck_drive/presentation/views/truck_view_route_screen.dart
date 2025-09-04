import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/active_truck_route_provider.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/notification_api_provider.dart';
import 'package:comaslimpio/core/models/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
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
    
    final location = Location(
      lat: _currentPosition!.latitude,
      long: _currentPosition!.longitude,
    );

    // Actualizar solo Firestore para datos del conductor (sin trigger de notificaciones)
    try {
      await FirebaseFirestore.instance.collection('app_users').doc(userId).update({
        'location': {
          'lat': location.lat,
          'long': location.long,
        },
      });
      print('✅ Firestore updated successfully');
    } catch (e) {
      print('❌ Firestore update error: $e');
    }

    // Enviar a API TypeScript para control total de notificaciones
    try {
      final apiNotifier = ref.read(notificationApiProvider.notifier);
      final success = await apiNotifier.updateTruckLocation(
        userId: userId,
        location: location,
      );
      
      if (success) {
        print('✅ TypeScript API processed notifications successfully');
      } else {
        print('❌ TypeScript API notification processing failed');
      }
    } catch (e) {
      print('❌ TypeScript API error: $e');
    }
  }

  Future<void> _sendTestNotification(String userId) async {
    final apiNotifier = ref.read(notificationApiProvider.notifier);
    final success = await apiNotifier.sendTestNotification(userId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notificación de prueba enviada'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error al enviar notificación de prueba'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkApiHealth() async {
    final apiNotifier = ref.read(notificationApiProvider.notifier);
    await apiNotifier.checkApiHealth();
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
    final apiState = ref.watch(notificationApiProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ver mi ruta'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
        actions: [
          // Indicador de estado de API
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(
                  apiState.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: apiState.isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  apiState.isConnected ? 'API OK' : 'API Error',
                  style: TextStyle(
                    color: apiState.isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
      floatingActionButton: user != null ? _buildDebugFAB(user.uid) : null,
    );
  }

  Widget _buildDebugFAB(String userId) {
    final apiState = ref.watch(notificationApiProvider);
    
    return FloatingActionButton(
      onPressed: () => _showApiDebugDialog(userId),
      backgroundColor: AppTheme.primary,
      child: Icon(
        apiState.isLoading ? Icons.hourglass_empty : Icons.api,
        color: Colors.white,
      ),
    );
  }

  void _showApiDebugDialog(String userId) {
    final apiState = ref.watch(notificationApiProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              apiState.isConnected ? Icons.check_circle : Icons.error,
              color: apiState.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            const Text('API de Notificaciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: ${apiState.isConnected ? "Conectada" : "Desconectada"}'),
            if (apiState.lastError != null)
              Text('Error: ${apiState.lastError}', style: const TextStyle(color: Colors.red)),
            Text('Notificaciones enviadas: ${apiState.notificationsSent}'),
            if (apiState.lastUpdate != null)
              Text('Última actualización: ${apiState.lastUpdate!.toLocal().toString().substring(11, 19)}'),
            const SizedBox(height: 16),
            const Text('Logs recientes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 150,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Text(
                  apiState.logs.reversed.take(10).join('\n'),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _checkApiHealth();
              context.pop();
            },
            child: const Text('Verificar Estado'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              await _sendTestNotification(userId);
            },
            child: const Text('Probar Notificación'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
