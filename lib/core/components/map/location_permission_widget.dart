import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:comaslimpio/core/components/map/map_location_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class LocationPermissionWidget extends ConsumerWidget {
  const LocationPermissionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapLocationState = ref.watch(mapLocationProvider);
    final mapLocationNotifier = ref.read(mapLocationProvider.notifier);

    // Si ya tenemos permisos o está cargando, no mostrar nada
    if (mapLocationState.permissionStatus == LocationPermissionStatus.granted ||
        mapLocationState.isLoading) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _getIconForStatus(mapLocationState.permissionStatus),
              size: 48,
              color: _getColorForStatus(mapLocationState.permissionStatus),
            ),
            const SizedBox(height: 12),
            Text(
              _getTitleForStatus(mapLocationState.permissionStatus),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getDescriptionForStatus(mapLocationState.permissionStatus),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildActionButton(context, mapLocationState.permissionStatus, mapLocationNotifier),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return Icons.location_off;
      case LocationPermissionStatus.deniedForever:
        return Icons.location_disabled;
      case LocationPermissionStatus.serviceDisabled:
        return Icons.gps_off;
      default:
        return Icons.location_on;
    }
  }

  Color _getColorForStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return Colors.orange;
      case LocationPermissionStatus.deniedForever:
        return Colors.red;
      case LocationPermissionStatus.serviceDisabled:
        return Colors.grey;
      default:
        return AppTheme.primary;
    }
  }

  String _getTitleForStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return 'Permisos de ubicación requeridos';
      case LocationPermissionStatus.deniedForever:
        return 'Permisos de ubicación denegados';
      case LocationPermissionStatus.serviceDisabled:
        return 'Servicios de ubicación deshabilitados';
      default:
        return 'Configurar ubicación';
    }
  }

  String _getDescriptionForStatus(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return 'Para una mejor experiencia, necesitamos acceso a tu ubicación. Esto nos ayuda a mostrarte el mapa de tu zona.';
      case LocationPermissionStatus.deniedForever:
        return 'Los permisos de ubicación han sido denegados permanentemente. Ve a Configuración para habilitarlos manualmente.';
      case LocationPermissionStatus.serviceDisabled:
        return 'Los servicios de ubicación están deshabilitados en tu dispositivo. Actívalos en Configuración.';
      default:
        return 'Configura los permisos de ubicación';
    }
  }

  Widget _buildActionButton(BuildContext context, LocationPermissionStatus status, MapLocationNotifier notifier) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return ElevatedButton.icon(
          onPressed: () => notifier.requestLocationPermission(),
          icon: const Icon(Icons.location_on),
          label: const Text('Permitir ubicación'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
        );
      case LocationPermissionStatus.deniedForever:
        return ElevatedButton.icon(
          onPressed: () => Geolocator.openAppSettings(),
          icon: const Icon(Icons.settings),
          label: const Text('Abrir configuración'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        );
      case LocationPermissionStatus.serviceDisabled:
        return ElevatedButton.icon(
          onPressed: () => Geolocator.openLocationSettings(),
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Activar ubicación'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}