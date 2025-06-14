import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../mappers/route_mapper.dart';

class RouteFirebaseDatasource implements RouteRepository {
  final FirestoreService _firestoreService;

  RouteFirebaseDatasource(this._firestoreService);

  // Métodos Future
  @override
  Future<List<Route>> getAllRoutes() async {
    final docs = await _firestoreService.getDocuments('routes');
    return docs
        .map((doc) => RouteMapper.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Route>> getRoutesByTruckDriver(String truckDriverId) async {
    final snapshot = await _firestoreService
        .collection('routes')
        .where('id_truck_drivers', isEqualTo: truckDriverId)
        .get();
    return snapshot.docs
        .map((doc) => RouteMapper.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Route?> getRouteById(String id) async {
    final doc = await _firestoreService.getDocument('routes', id);
    if (!doc.exists) return null;
    return RouteMapper.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addRoute(Route route) async {
    await _firestoreService.setDocument(
      'routes',
      route.uid,
      RouteMapper.toJson(route),
    );
  }

  @override
  Future<void> updateRoute(Route route) async {
    await _firestoreService.updateDocument(
      'routes',
      route.uid,
      RouteMapper.toJson(route),
    );
  }

  @override
  Future<void> deleteRoute(String id) async {
    await _firestoreService.collection('routes').doc(id).delete();
  }

  // Métodos Stream
  @override
  Stream<List<Route>> watchAllRoutes() {
    return _firestoreService
        .streamCollection('routes')
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    RouteMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Route>> watchRoutesByTruckDriver(String truckDriverId) {
    return _firestoreService
        .streamCollectionWhere('routes', 'id_truck_drivers', truckDriverId)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    RouteMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<List<Route>> watchActiveRoutes() {
    return _firestoreService
        .streamCollectionWhere('routes', 'status', 'active')
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    RouteMapper.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Stream<Route?> watchRouteById(String id) {
    return _firestoreService
        .streamDocument('routes', id)
        .map(
          (doc) => doc.exists
              ? RouteMapper.fromJson(doc.data() as Map<String, dynamic>)
              : null,
        );
  }
}
