import 'package:comaslimpio/features/truck_drive/domain/models/truck_driver.dart';

abstract class TruckDriverRepository {
  Future<List<TruckDriver>> getAllTruckDrivers();
  Future<TruckDriver?> getTruckDriverById(String id);
  Future<void> addTruckDriver(TruckDriver truckDriver);
  Future<void> updateTruckDriver(TruckDriver truckDriver);
  Future<void> deleteTruckDriver(String id);
}