import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route.dart';
import '../../domain/repositories/route_repository.dart';

class RouteState {
  final List<Route> routes;
  final bool isLoading;
  final String? error;

  RouteState({this.routes = const [], this.isLoading = false, this.error});

  RouteState copyWith({List<Route>? routes, bool? isLoading, String? error}) {
    return RouteState(
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RouteViewModel extends StateNotifier<RouteState> {
  final RouteRepository _repository;

  RouteViewModel(this._repository) : super(RouteState());

  Future<void> loadRoutes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final routes = await _repository.getAllRoutes();
      state = state.copyWith(routes: routes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadRoutesByTruckDriver(String truckDriverId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final routes = await _repository.getRoutesByTruckDriver(truckDriverId);
      state = state.copyWith(routes: routes, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addRoute(Route route) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.addRoute(route);
      await loadRoutes();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateRoute(Route route) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateRoute(route);
      await loadRoutes();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteRoute(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteRoute(id);
      await loadRoutes();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
