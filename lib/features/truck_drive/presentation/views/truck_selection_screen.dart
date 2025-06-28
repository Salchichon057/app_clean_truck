import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comaslimpio/features/truck_drive/presentation/providers/truck_provider.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/core/presentation/theme/app_theme.dart';

class TruckSelectionScreen extends ConsumerWidget {
  const TruckSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trucksAsync = ref.watch(availableTrucksStreamProvider);
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
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trucks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final truck = trucks[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    color: AppTheme.primary,
                  ),
                  title: Text('${truck.brand} ${truck.model}'),
                  subtitle: Text('Placa: ${truck.idTruck}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: user == null
                        ? null
                        : () async {
                            final truckNotifier = ref.read(
                              truckViewModelProvider.notifier,
                            );
                            await truckNotifier.updateTruck(
                              truck.copyWith(idAppUser: user.uid),
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: const Text('Seleccionar'),
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
