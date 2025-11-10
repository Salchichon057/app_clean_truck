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
    bool isCurrentlySelected,
  ) async {
    // Validación adicional: si no está seleccionado, verificar que el usuario no tenga otro camión
    if (!isCurrentlySelected) {
      final trucksAsync = ref.read(availableAndMyTruckStreamProvider);
      final hasAnotherTruck = await trucksAsync.when(
        data: (trucks) async {
          return trucks.any((t) => t.idAppUser == user.uid && t.idTruck != truck.idTruck);
        },
        loading: () async => false,
        error: (_, __) async => false,
      );
      
      if (hasAnotherTruck) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya tienes un camión seleccionado. Deselecciónalo primero.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isCurrentlySelected ? 'Deseleccionar camión' : 'Confirmar selección'),
        content: Text(
          isCurrentlySelected
              ? '¿Deseas deseleccionar el camión ${truck.brand} ${truck.model} (Placa: ${truck.idTruck})?'
              : '¿Deseas seleccionar el camión ${truck.brand} ${truck.model} (Placa: ${truck.idTruck})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlySelected ? Colors.orange : AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isCurrentlySelected ? 'Deseleccionar' : 'Confirmar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && user != null) {
      final truckNotifier = ref.read(truckViewModelProvider.notifier);
      
      if (isCurrentlySelected) {
        // Deseleccionar: liberar el camión
        await truckNotifier.updateTruck(
          truck.copyWith(idAppUser: null, status: 'available'),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camión deseleccionado correctamente'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Seleccionar nuevo: SIEMPRE liberar todos los camiones del usuario primero
        final trucksAsync = ref.read(availableAndMyTruckStreamProvider);
        
        await trucksAsync.when(
          data: (trucks) async {
            // Liberar TODOS los camiones que tenga el usuario asignados
            final myTrucks = trucks.where((t) => t.idAppUser == user.uid).toList();
            
            for (final previousTruck in myTrucks) {
              await truckNotifier.updateTruck(
                previousTruck.copyWith(idAppUser: null, status: 'available'),
              );
            }
            
            // Esperar a que se actualice en Firestore
            if (myTrucks.isNotEmpty) {
              await Future.delayed(const Duration(milliseconds: 800));
            }
            
            // Ahora seleccionar el nuevo camión
            await truckNotifier.updateTruck(
              truck.copyWith(idAppUser: user.uid, status: 'unavailable'),
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camión seleccionado correctamente'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          loading: () async {},
          error: (e, _) async {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 600));
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
          String? myTruckId;
          if (user != null) {
            for (final truck in trucks) {
              if (truck.idAppUser == user.uid) {
                myTruckId = truck.idTruck;
                break;
              }
            }
          }

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
              
              // Si hay un camión seleccionado Y no es este, está deshabilitado
              final isDisabled = myTruckId != null && myTruckId.isNotEmpty && !isSelected;

              return Opacity(
                opacity: isDisabled ? 0.4 : 1.0,
                child: Card(
                  elevation: isSelected ? 3 : 2,
                  color: isDisabled ? Colors.grey[300] : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: AppTheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_shipping,
                      color: isDisabled 
                          ? Colors.grey
                          : AppTheme.primary.withValues(alpha: 0.8),
                    ),
                    title: Text(
                      '${truck.brand} ${truck.model}',
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(
                      'Placa: ${truck.idTruck}',
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    onTap: user == null || isDisabled
                        ? null
                        : () => _showConfirmationDialog(context, truck, user, isSelected),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.tertiary)
                        : null,
                  ),
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
