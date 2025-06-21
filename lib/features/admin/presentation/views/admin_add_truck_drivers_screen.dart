import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/add_truck_driver_dialog.dart';
import '../providers/truck_driver_list_provider.dart';

class AdminAddTruckDriversScreen extends ConsumerWidget {
  const AdminAddTruckDriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final truckDriversAsync = ref.watch(truckDriverListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductores de Camión'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
      ),
      body: truckDriversAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No hay conductores registrados.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
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
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(
                              item.status == "available"
                                  ? "Disponible"
                                  : "No disponible",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: item.status == "available"
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.badge, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(
                            'DNI: ${item.dni}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(
                            item.email,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(
                            item.phoneNumber,
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      if (item.status == "unavailable" &&
                          item.truckId != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'Camión asignado: ${item.truckId}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.primary,
                            ),
                          ],
                        ),
                      ],
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
          showDialog(
            context: context,
            builder: (_) => const AddTruckDriverDialog(),
          );
        },
        fillColor: AppTheme.primary,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
