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
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    item.user?.name ?? 'Sin nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DNI: ${item.user?.dni ?? "-"}'),
                      Text('Correo: ${item.user?.email ?? "-"}'),
                      Text('Teléfono: ${item.user?.phoneNumber ?? "-"}'),
                      Text(
                        'Ubicación: ${item.user?.location.lat ?? "-"}, ${item.user?.location.long ?? "-"}',
                      ),
                      Text(
                        'Camión: ${item.truck?.brand ?? "-"} - ${item.truck?.model ?? "-"}',
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.local_shipping,
                    color: AppTheme.primary,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Conductor'),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddTruckDriverDialog(),
        ),
      ),
    );
  }
}
