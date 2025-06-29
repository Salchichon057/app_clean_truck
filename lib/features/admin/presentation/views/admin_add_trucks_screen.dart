import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:comaslimpio/features/admin/presentation/providers/route_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/features/admin/presentation/widgets/truck_form_dialog.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_driver_name_provider.dart';

class AdminAddTrucksScreen extends ConsumerWidget {
  const AdminAddTrucksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucksAsync = ref.watch(trucksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camiones'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
      ),
      body: trucksAsync.when(
        data: (trucks) {
          if (trucks.isEmpty) {
            return const Center(child: Text('No hay camiones registrados.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trucks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final truck = trucks[index];
              return _TruckCard(truck: truck);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: RawMaterialButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const TruckFormDialog());
        },
        fillColor: Theme.of(context).primaryColor,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

class _TruckCard extends ConsumerWidget {
  final Truck truck;
  const _TruckCard({required this.truck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(activeRoutesStreamProvider);
    final driverNameAsync = ref.watch(truckDriverNameProvider(truck.idAppUser));

    return routesAsync.when(
      data: (routes) {
        final assignedRoute =
            routes.where((r) => r.idTruck == truck.idTruck).isNotEmpty
            ? routes.firstWhere((r) => r.idTruck == truck.idTruck)
            : null;
        final isAvailable = truck.idAppUser == null;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del camión
                Container(
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.local_shipping,
                    color: isAvailable ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${truck.brand} ${truck.model}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placa: ${truck.idTruck}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Año: ${truck.yearOfManufacture}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Text(
                      //   isAvailable
                      //       ? 'Estado: Disponible'
                      //       : 'Estado: No disponible',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: isAvailable ? Colors.green : Colors.red,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          assignedRoute != null
                              ? 'Ruta: ${assignedRoute.routeName}'
                              : 'Ruta: No seleccionada',
                          style: TextStyle(
                            fontSize: 14,
                            color: assignedRoute != null
                                ? AppTheme.primary
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      driverNameAsync.when(
                        data: (name) => name != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Conductor: $name',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Text('Conductor: No asignado',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                        loading: () => const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (e, _) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert, color: AppTheme.primary),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (_) => TruckFormDialog(truck: truck),
                      );
                    } else if (value == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar camión'),
                          content: const Text(
                            '¿Estás seguro de eliminar este camión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final truckNotifier = ref.read(
                          truckViewModelProvider.notifier,
                        );
                        await truckNotifier.deleteTruck(truck.idTruck);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar camión'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Eliminar camión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error cargando rutas: $e'),
        ),
      ),
    );
  }
}
