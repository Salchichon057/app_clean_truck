import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_on_map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/available_and_my_truck_stream_provider.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class TruckSelectionScreen extends ConsumerStatefulWidget {
  const TruckSelectionScreen({super.key});

  @override
  ConsumerState<TruckSelectionScreen> createState() =>
      _TruckSelectionScreenState();
}

class _TruckSelectionScreenState extends ConsumerState<TruckSelectionScreen> {
  Future<void> _showConfirmationDialog(
    BuildContext context,
    truck,
    user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Confirmar selección'),
        content: Text(
          '¿Deseas seleccionar el camión ${truck.brand} ${truck.model} (Placa: ${truck.idTruck})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed == true && user != null) {
      final truckNotifier = ref.read(truckViewModelProvider.notifier);
      await truckNotifier.updateTruck(
        truck.copyWith(idAppUser: user.uid, status: 'unavailable'),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted && Navigator.of(context).canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trucksAsync = ref.watch(availableAndMyTruckStreamProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Camión'),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
      ),
      body: trucksAsync.when(
        data: (trucks) {
          if (trucks.isEmpty) {
            return const Center(child: Text('No hay camiones disponibles.'));
          }

          // Encuentra el camión asignado al usuario actual
          final myTruckId = user == null
              ? null
              : trucks
                    .firstWhereOrNull((t) => t.idAppUser == user.uid)
                    ?.idTruck;

          // Si hay uno seleccionado, lo llevamos arriba
          final sortedTrucks = [...trucks];
          if (myTruckId != null) {
            sortedTrucks.sort((a, b) {
              if (a.idTruck == myTruckId) return -1;
              if (b.idTruck == myTruckId) return 1;
              return 0;
            });
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTrucks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final truck = sortedTrucks[index];
              final isSelected = user != null && truck.idAppUser == user.uid;

              return Card(
                elevation: isSelected ? 3 : 2,
                color: null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: AppTheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.local_shipping,
                    color: AppTheme.primary.withValues(alpha: 0.8),
                  ),
                  title: Text('${truck.brand} ${truck.model}'),
                  subtitle: Text('Placa: ${truck.idTruck}'),
                  onTap: user == null
                      ? null
                      : () => _showConfirmationDialog(context, truck, user),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.tertiary)
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
