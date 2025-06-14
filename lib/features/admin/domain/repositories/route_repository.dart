import '../models/route.dart';

abstract class RouteRepository {
  // Métodos Future
  Future<List<Route>> getAllRoutes();
  Future<List<Route>> getRoutesByTruckDriver(String truckDriverId);
  Future<Route?> getRouteById(String id);
  Future<void> addRoute(Route route);
  Future<void> updateRoute(Route route);
  Future<void> deleteRoute(String id);

  // Métodos Stream
  Stream<List<Route>> watchAllRoutes();
  Stream<List<Route>> watchRoutesByTruckDriver(String truckDriverId);
  Stream<List<Route>> watchActiveRoutes();
  Stream<Route?> watchRouteById(String id);
}
