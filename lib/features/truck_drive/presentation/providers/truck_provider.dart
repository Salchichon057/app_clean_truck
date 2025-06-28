import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/auth/presentation/providers/auth_providers.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';
import 'package:comaslimpio/features/truck_drive/presentation/viewmodels/truck_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../../infrastructure/datasources/truck_firebase_datasource.dart';
import '../../domain/repositories/truck_repository.dart';

final truckRepositoryProvider = Provider<TruckRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TruckFirebaseDatasource(firestoreService);
});

final truckViewModelProvider =
    StateNotifierProvider<TruckViewModel, TruckState>((ref) {
      final repo = ref.watch(truckRepositoryProvider);
      return TruckViewModel(repo);
    });

// Stream Providers
final trucksStreamProvider = StreamProvider<List<Truck>>((ref) {
  final repo = ref.watch(truckRepositoryProvider);
  return repo.watchAllTrucks();
});

final userTrucksStreamProvider = StreamProvider<List<Truck>>((ref) {
  final truckRepo = ref.watch(truckRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  final availableStream = truckRepo.watchTrucksByStatus('available');
  final myTruckStream = user == null
      ? Stream.value(<Truck>[])
      : truckRepo.watchTrucksByUser(user.uid);

  // Combina ambos streams
  return Rx.combineLatest2<List<Truck>, List<Truck>, List<Truck>>(
    availableStream,
    myTruckStream,
    (available, mine) {
      // Une y elimina duplicados por idTruck
      final all = [...available, ...mine];
      final unique = <String, Truck>{};
      for (final t in all) {
        unique[t.idTruck] = t;
      }
      return unique.values.toList();
    },
  );
});
final truckByIdStreamProvider = StreamProvider.family<Truck?, String>((
  ref,
  id,
) {
  final repo = ref.watch(truckRepositoryProvider);
  return repo.watchTruckById(id);
});
