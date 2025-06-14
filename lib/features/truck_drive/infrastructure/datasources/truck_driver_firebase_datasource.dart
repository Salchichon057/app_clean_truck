import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/truck_driver.dart';
import '../../domain/repositories/truck_driver_repository.dart';
import '../mappers/truck_driver_mapper.dart';

class TruckDriverFirebaseDatasource implements TruckDriverRepository {
  final FirestoreService _firestoreService;

  TruckDriverFirebaseDatasource(this._firestoreService);

  // Métodos Future
  @override
  Future<List<TruckDriver>> getAllTruckDrivers() async {
    final docs = await _firestoreService.getDocuments('truck_drivers');
    return docs
        .map(
          (doc) =>
              TruckDriverMapper.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<TruckDriver?> getTruckDriverById(String id) async {
    final doc = await _firestoreService.getDocument('truck_drivers', id);
    if (!doc.exists) return null;
    return TruckDriverMapper.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addTruckDriver(TruckDriver truckDriver) async {
    await _firestoreService.setDocument(
      'truck_drivers',
      truckDriver.uid,
      TruckDriverMapper.toJson(truckDriver),
    );
  }

  @override
  Future<void> updateTruckDriver(TruckDriver truckDriver) async {
    await _firestoreService.updateDocument(
      'truck_drivers',
      truckDriver.uid,
      TruckDriverMapper.toJson(truckDriver),
    );
  }

  @override
  Future<void> deleteTruckDriver(String id) async {
    await _firestoreService.collection('truck_drivers').doc(id).delete();
  }

  // Métodos Stream
  @override
  Stream<List<TruckDriver>> watchAllTruckDrivers() {
    return _firestoreService
        .streamCollection('truck_drivers')
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TruckDriverMapper.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<TruckDriver>> watchTruckDriversByTruck(String truckId) {
    return _firestoreService
        .streamCollectionWhere('truck_drivers', 'id_truck', truckId)
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TruckDriverMapper.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<TruckDriver?> watchTruckDriverById(String id) {
    return _firestoreService
        .streamDocument('truck_drivers', id)
        .map(
          (doc) => doc.exists
              ? TruckDriverMapper.fromJson(doc.data() as Map<String, dynamic>)
              : null,
        );
  }
}
