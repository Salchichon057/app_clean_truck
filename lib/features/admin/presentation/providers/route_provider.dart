import 'package:comaslimpio/core/services/firestore_service.dart';
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
