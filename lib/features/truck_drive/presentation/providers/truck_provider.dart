import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/truck_drive/presentation/viewmodels/truck_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
