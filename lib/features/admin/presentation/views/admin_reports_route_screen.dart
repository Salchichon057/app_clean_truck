import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/admin/presentation/providers/incidents_with_user_provider.dart';
import 'package:comaslimpio/features/citizen/presentation/components/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminReportsRouteScreen extends ConsumerWidget {
  const AdminReportsRouteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsByDate = ref.watch(incidentsWithUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Incidentes'),
        foregroundColor: AppTheme.primary,
        backgroundColor: Colors.transparent,
      ),
      body: incidentsByDate.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const Center(child: Text('No hay reportes de rutas.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return IncidentCard(
                incident: incident.incident,
                userName: incident.userName ?? 'Usuario Desconocido',
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errores: $e')),
      ),
    );
  }
}
