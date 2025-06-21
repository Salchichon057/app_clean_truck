import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/citizen/presentation/components/incident_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/user_incidents_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class CitizenIncidentHistoryScreen extends ConsumerWidget {
  const CitizenIncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(userIncidentsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Incidentes'),
        foregroundColor: AppTheme.primary,
        backgroundColor: Colors.transparent,
      ),
      body: incidentsAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const Center(child: Text('No has reportado incidentes.'));
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
