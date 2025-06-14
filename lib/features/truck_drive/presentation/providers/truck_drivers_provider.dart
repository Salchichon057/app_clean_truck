import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/truck_drive/domain/models/truck_driver.dart';
import 'package:comaslimpio/features/truck_drive/presentation/viewmodels/truck_driver_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/datasources/truck_driver_firebase_datasource.dart';
import '../../domain/repositories/truck_driver_repository.dart';

final truckDriverRepositoryProvider = Provider<TruckDriverRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return TruckDriverFirebaseDatasource(firestoreService);
});

final truckDriverViewModelProvider =
    StateNotifierProvider<TruckDriverViewModel, TruckDriverState>((ref) {
      final repo = ref.watch(truckDriverRepositoryProvider);
      return TruckDriverViewModel(repo);
    });

// Stream Providers
final truckDriversStreamProvider = StreamProvider<List<TruckDriver>>((ref) {
  final repo = ref.watch(truckDriverRepositoryProvider);
  return repo.watchAllTruckDrivers();
});

final truckDriversByTruckStreamProvider =
    StreamProvider.family<List<TruckDriver>, String>((ref, truckId) {
      final repo = ref.watch(truckDriverRepositoryProvider);
      return repo.watchTruckDriversByTruck(truckId);
    });

final truckDriverByIdStreamProvider =
    StreamProvider.family<TruckDriver?, String>((ref, id) {
      final repo = ref.watch(truckDriverRepositoryProvider);
      return repo.watchTruckDriverById(id);
    });
