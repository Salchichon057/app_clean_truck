import 'truck.dart';
import 'truck_driver.dart';
import 'package:comaslimpio/features/auth/domain/models/app_user.dart';

class TruckOnMap {
  final Truck truck;
  final TruckDriver truckDriver;
  final AppUser driverUser;

  TruckOnMap({
    required this.truck,
    required this.truckDriver,
    required this.driverUser,
  });
}
