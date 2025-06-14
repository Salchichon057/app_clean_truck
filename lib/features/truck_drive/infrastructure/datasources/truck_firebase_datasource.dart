import 'package:comaslimpio/core/services/firestore_service.dart';
import '../../domain/models/truck.dart';
import '../../domain/repositories/truck_repository.dart';
import '../mappers/truck_mapper.dart';

class TruckFirebaseDatasource implements TruckRepository {
  final FirestoreService _firestoreService;

  TruckFirebaseDatasource(this._firestoreService);

  @override
  Future<List<Truck>> getAllTrucks() async {
    final docs = await _firestoreService.getDocuments('trucks');
    return docs
        .map((doc) => TruckMapper.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Truck?> getTruckById(String id) async {
    final doc = await _firestoreService.getDocument('trucks', id);
    if (!doc.exists) return null;
    return TruckMapper.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addTruck(Truck truck) async {
    await _firestoreService.setDocument(
      'trucks',
      truck.idTruck,
      TruckMapper.toJson(truck),
    );
  }

  @override
  Future<void> updateTruck(Truck truck) async {
    await _firestoreService.updateDocument(
      'trucks',
      truck.idTruck,
      TruckMapper.toJson(truck),
    );
  }

  @override
  Future<void> deleteTruck(String id) async {
    await _firestoreService.collection('trucks').doc(id).delete();
  }
}
