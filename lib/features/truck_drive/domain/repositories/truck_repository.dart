import '../models/truck.dart';

abstract class TruckRepository {
  // Métodos Future (operaciones puntuales)
  Future<List<Truck>> getAllTrucks();
  Future<Truck?> getTruckById(String id);
  Future<void> addTruck(Truck truck);
  Future<void> updateTruck(Truck truck);
  Future<void> deleteTruck(String id);
  Future<List<Truck>> getTrucksByUser(String userId);

  // Métodos Stream (tiempo real)
  Stream<List<Truck>> watchAllTrucks();
  Stream<List<Truck>> watchTrucksByStatus(String status);
  Stream<Truck?> watchTruckById(String id);
  Stream<List<Truck>> watchTrucksByUser(String userId);
}
