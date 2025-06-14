import '../models/truck_driver.dart';

abstract class TruckDriverRepository {
  // Métodos Future
  Future<List<TruckDriver>> getAllTruckDrivers();
  Future<TruckDriver?> getTruckDriverById(String id);
  Future<void> addTruckDriver(TruckDriver truckDriver);
  Future<void> updateTruckDriver(TruckDriver truckDriver);
  Future<void> deleteTruckDriver(String id);

  // Métodos Stream
  Stream<List<TruckDriver>> watchAllTruckDrivers();
  Stream<List<TruckDriver>> watchTruckDriversByTruck(String truckId);
  Stream<TruckDriver?> watchTruckDriverById(String id);
}
