import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/route.dart';
import '../../domain/repositories/route_repository.dart';
import '../mappers/route_mapper.dart';

class RouteFirebaseDatasource implements RouteRepository {
  final FirestoreService _firestoreService;

  RouteFirebaseDatasource(this._firestoreService);

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
}
