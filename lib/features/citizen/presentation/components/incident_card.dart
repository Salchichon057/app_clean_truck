import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/features/admin/presentation/widgets/incident_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/citizen/domain/models/incident.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/core/presentation/widgets/location_map_preview.dart';
import 'package:comaslimpio/features/citizen/presentation/providers/incident_address_provider.dart';

class IncidentCard extends ConsumerWidget {
  final Incident incident;
  final String userName;
  const IncidentCard({
    super.key,
    required this.incident,
    this.userName = 'Usuario Desconocido',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressAsync = ref.watch(incidentAddressProvider(incident.location));

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        final address = addressAsync.maybeWhen(
          data: (addr) => addr,
          orElse: () => null,
        );
        showDialog(
          context: context,
          builder: (context) => IncidentDetailDialog(
            incident: incident,
            userName: userName,
            address: address,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 1,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del usuario que reportó el incidente
              Row(
                children: [
                  const Icon(Icons.person, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident.description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fecha: ${_formatDate(incident.date)}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              addressAsync.when(
                data: (address) => Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppTheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address ?? 'Dirección no disponible',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                loading: () => const Text(
                  'Cargando dirección...',
                  style: TextStyle(color: AppTheme.primary),
                ),
                error: (_, __) => const Text(
                  'Dirección no disponible',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Estado: ${incident.status}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LocationMapPreview(
                location: incident.location,
                height: 120,
                borderRadius: 10,
              ),
            ],
          ),
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
