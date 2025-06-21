import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/route_provider.dart';

class AdminMapsScreen extends ConsumerWidget {
  const AdminMapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas registradas'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) {
            return const Center(child: Text('No hay rutas registradas.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: routes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
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
                            label: Text(
                              route.status == "active" ? "Activa" : "Inactiva",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: route.status == "active"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(route.date),
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Camión: ${route.idTruck}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () {
          context.push('/admin/manage_routes');
        },
        fillColor: AppTheme.primary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
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
