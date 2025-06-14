import 'package:comaslimpio/features/admin/domain/models/route.dart';

abstract class RouteRepository {
  Future<List<Route>> getAllRoutes();
  Future<List<Route>> getRoutesByTruckDriver(String truckDriverId);
  Future<Route?> getRouteById(String id);
  Future<void> addRoute(Route route);
  Future<void> updateRoute(Route route);
  Future<void> deleteRoute(String id);
}
