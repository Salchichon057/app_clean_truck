import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/citizen/presentation/components/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/user_incidents_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/selected_route_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class CitizenIncidentHistoryScreen extends ConsumerWidget {
  const CitizenIncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(userIncidentsProvider);
    final user = ref.watch(currentUserProvider);
    final selectedRoute = ref.watch(selectedRouteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Incidentes'),
        foregroundColor: AppTheme.primary,
        backgroundColor: Colors.transparent,
      ),
      body: incidentsAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            if (selectedRoute == null) {
              // No hay ruta seleccionada
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alt_route,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes una ruta seleccionada',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona una ruta desde el mapa\npara poder reportar incidentes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            } else {
              // Hay ruta seleccionada pero no incidentes
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.report_gmailerrorred,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No has reportado incidentes.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa el botón del mapa para reportar\nincidentes en tu ruta seleccionada.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ruta: ${selectedRoute.routeName}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return IncidentCard(incident: incident, userName: user?.name ?? 'Usuario Desconocido');
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
