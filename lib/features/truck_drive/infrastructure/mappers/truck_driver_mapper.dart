import '../../domain/models/truck_driver.dart';

class TruckDriverMapper {
  static TruckDriver fromJson(Map<String, dynamic> json) {
    return TruckDriver(
      uid: json['uid'],
      idTruck: json['id_truck'],
      uidUsers: json['uid_users'],
    );
  }

  static Map<String, dynamic> toJson(TruckDriver truckDriver) {
    return {
      'uid': truckDriver.uid,
      'id_truck': truckDriver.idTruck,
      'uid_users': truckDriver.uidUsers,
    };
  }
}
