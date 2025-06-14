import 'package:comaslimpio/features/truck_drive/domain/models/truck.dart';

abstract class TruckRepository {
  Future<List<Truck>> getAllTrucks();
  Future<Truck?> getTruckById(String id);
  Future<void> addTruck(Truck truck);
  Future<void> updateTruck(Truck truck);
  Future<void> deleteTruck(String id);
}
