import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/user_incidents_provider.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';

class CitizenIncidentHistoryScreen extends ConsumerWidget {
  const CitizenIncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(userIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Incidentes'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
              return IncidentCard(incident: incident);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class IncidentCard extends StatelessWidget {
  final Incident incident;
  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.description,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${_formatDate(incident.date)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primary, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Lat: ${incident.location.lat.toStringAsFixed(5)}, Long: ${incident.location.long.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Estado: ${incident.status}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}