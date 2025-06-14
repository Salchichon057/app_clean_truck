import 'package:comaslimpio/core/services/firestore_service.dart';
import 'package:comaslimpio/features/admin/domain/models/route.dart';
import 'package:comaslimpio/features/admin/presentation/viewmodels/route_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/datasources/route_firebase_datasource.dart';
import '../../domain/repositories/route_repository.dart';

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return RouteFirebaseDatasource(firestoreService);
});

final routeViewModelProvider =
    StateNotifierProvider<RouteViewModel, RouteState>((ref) {
      final repo = ref.watch(routeRepositoryProvider);
      return RouteViewModel(repo);
    });

// Stream Providers
final routesStreamProvider = StreamProvider<List<Route>>((ref) {
  final repo = ref.watch(routeRepositoryProvider);
  return repo.watchAllRoutes();
});

final routesByTruckDriverStreamProvider =
    StreamProvider.family<List<Route>, String>((ref, truckDriverId) {
      final repo = ref.watch(routeRepositoryProvider);
      return repo.watchRoutesByTruckDriver(truckDriverId);
    });

final activeRoutesStreamProvider = StreamProvider<List<Route>>((ref) {
  final repo = ref.watch(routeRepositoryProvider);
  return repo.watchActiveRoutes();
});

final routeByIdStreamProvider = StreamProvider.family<Route?, String>((
  ref,
  id,
) {
  final repo = ref.watch(routeRepositoryProvider);
  return repo.watchRouteById(id);
});
